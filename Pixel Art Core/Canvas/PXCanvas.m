//
//  PXCanvas.m
//  Pixen
//

#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Drawing.h"
#import "PXCanvas_Backgrounds.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Layers.h"
#import "PXLayer.h"
#import "PXBackgroundConfig.h"

@implementation PXCanvas {
	NSOperationQueue *_frequencyQueue;
	PXPalette *_frequencyPalette;
}

@synthesize tempLayers, grid;

- (id)copyWithZone:(NSZone *)zone
{
	return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

- (void)recacheSize
{
	canvasRect = NSMakeRect(0, 0, [self size].width, [self size].height);
}

- (id)init
{
	if ( ! (self = [super init]))
		return nil;
	
	_minusColors = [[NSCountedSet alloc] init];
	_plusColors = [[NSCountedSet alloc] init];
	
	_frequencyQueue = [NSOperationQueue new];
	[_frequencyQueue setMaxConcurrentOperationCount:1];
	[_frequencyQueue addObserver:self forKeyPath:@"operationCount" options:0 context:NULL];
	
	layers = [[NSMutableArray alloc] initWithCapacity:23];
	grid = [[PXGrid alloc] init];
	bgConfig = [[PXBackgroundConfig alloc] init];
	
	return self;
}

- (void)dealloc
{
	if (selectionMask)
		free(selectionMask);
	
	PXColorArrayRelease(_oldColors);
	PXColorArrayRelease(_newColors);
	
	[_frequencyQueue cancelAllOperations];
	[_frequencyQueue removeObserver:self forKeyPath:@"operationCount"];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"operationCount"]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:PXToggledFrequencyPaletteUpdationNotificationName
																object:self
															  userInfo:@{@"Value" : @([_frequencyQueue operationCount]>0)}];
		});
	}
}

- (void)setUndoManager:(NSUndoManager *)manager
{
	undoManager = manager;
//	[layers setValue:manager forKey:@"undoManager"];
}

- (NSUndoManager *)undoManager
{
	return undoManager;
}

- (NSSize)size
{
	if([layers count] > 0) {
		PXLayer *firstLayer = [layers objectAtIndex:0];
		return [firstLayer size];
	}
	
	return NSZeroSize;
}

- (void)updatePreviewSize
{
	canvasRect = NSMakeRect(0, 0, [self size].width, [self size].height);  //Cached because [self size] and NSMakeRect slow things down when containsPoint is called a bunch
	[self changed];
}

#pragma mark -
#pragma mark Frequency Palette

- (void)beginColorUpdates
{
	
}

- (void)updatePalette
{
	NSCountedSet *minusColorsCopy = [_minusColors copy];
	NSCountedSet *plusColorsCopy = [_plusColors copy];
	
	[_frequencyQueue addOperationWithBlock:^{
		
		for (NSColor *old in minusColorsCopy)
		{
			[_frequencyPalette decrementCountForColor:PXColorFromNSColor(old) byAmount:[minusColorsCopy countForObject:old]];
		}
		
		//can do 'recent palette' stuff here too. most draws will consist of one new and many old, so just consider the last 100 new?
		
		for (NSColor *new in plusColorsCopy)
		{
			PXColor color = PXColorFromNSColor(new);
			[_frequencyPalette incrementCountForColor:color byAmount:[plusColorsCopy countForObject:new]];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"AddedRecentColor"
																object:self
															  userInfo:@{@"Color": new}];
		}
		
		[_frequencyPalette sortByFrequency];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:PXUpdatedFrequencyPaletteNotificationName
																object:self
															  userInfo:@{@"Palette": [_frequencyPalette copy]}];
		});
		
	}];
}

- (void)endColorUpdates
{
	[self updatePalette];
	
	[_minusColors removeAllObjects];
	[_plusColors removeAllObjects];
}

- (void)refreshPalette
{
	[_frequencyQueue cancelAllOperations];
	
	NSArray *layersCopy = [[self layers] copy];
	
	NSBlockOperation *op = [[NSBlockOperation alloc] init];
	__weak NSBlockOperation *weakOp = op;
	
	[op addExecutionBlock:^{
		
		PXPalette *palette = [[PXPalette alloc] initWithoutBackgroundColor];
		
		PXLayer *firstLayer = [layersCopy objectAtIndex:0];
		
		CGFloat w = [firstLayer size].width;
		CGFloat h = [firstLayer size].height;
		
		for (PXLayer *current in layersCopy)
		{
			for (CGFloat i = 0; i < w; i++)
			{
				if ([weakOp isCancelled])
					return;
				
				for (CGFloat j = 0; j < h; j++)
				{
					PXColor color = [current colorAtPoint:NSMakePoint(i, j)];
					[palette incrementCountForColor:color byAmount:1];
				}
			}
		}
		
		[palette sortByFrequency];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			_frequencyPalette = palette;
			
			[[NSNotificationCenter defaultCenter] postNotificationName:PXUpdatedFrequencyPaletteNotificationName
																object:self
															  userInfo:@{@"Palette": [palette copy]}];
			
		});
		
	}];
	
	[_frequencyQueue addOperation:op];
}

//FIXME: write a single-layer variant of reallyRefreshWholePalette:
- (void)reallyRefreshWholePalette
{
	[self refreshPalette];
	
	frequencyPaletteDirty = NO;
	
	[_minusColors removeAllObjects];
	[_plusColors removeAllObjects];
}

- (void)refreshWholePalette
{
	if (!frequencyPaletteDirty) {
		frequencyPaletteDirty = YES;
		
		[[self class] cancelPreviousPerformRequestsWithTarget:self];
		[self performSelector:@selector(reallyRefreshWholePalette) withObject:nil afterDelay:0.5f];
	}
}

- (void)setSize:(NSSize)newSize withOrigin:(NSPoint)origin backgroundColor:(PXColor)color
{
	unsigned newMaskLength = sizeof(BOOL) * newSize.width * newSize.height;
	PXSelectionMask newMask = calloc(newSize.width * newSize.height, sizeof(BOOL));
	
	/* we'll just toss the selection when the canvas resizes.  that's not too heinous.
	int i, j;
	NSSize oldSize = [self size];
	int origin_x=origin.x, origin_y=origin.y; // pre-converting to integer
	for (j = 0; j < aSize.height; j++)
	{
		int src_y = (oldSize.height - (j - origin_y) - 1) * oldSize.width;
		int dst_y = (aSize.height - j - 1) * aSize.width;
		for (i = 0; i < aSize.width; i++)
		{
			if ((j - origin_y) < oldSize.height && (j - origin_y) >= 0 && (i - origin_x) < oldSize.width && (i - origin_x) >= 0) {
				newMask[dst_y + i] = selectionMask[src_y + i - origin_x];
			}
		}
	}*/
	if([layers count] > 0)
	{
		[self beginUndoGrouping]; {
			NSData *newData = [NSData dataWithBytes:newMask length:newMaskLength];
			NSData *oldData = [NSData dataWithBytes:selectionMask length:[self selectionMaskSize]];
			
			[self setLayersNoResize:[layers deepMutableCopy] fromLayers:layers];
			for (PXLayer *current in layers)
			{
				[current setSize:newSize withOrigin:origin backgroundColor:color];
			}
			[self setMaskData:newData withOldMaskData:oldData];
        //NSLog(@"Mask data updated - copied %@", [[layers lastObject] name]);
			free(newMask);
      [self refreshWholePalette];
		} [self endUndoGrouping];
	}
	else 
	{
		[self insertLayer:[[PXLayer alloc] initWithName:NSLocalizedString(@"Main Layer", @"Main Layer")
													size:newSize
										   fillWithColor:color] atIndex:0];
		
		[self reallyRefreshWholePalette];
		[self activateLayer:[layers objectAtIndex:0]];
		[[self undoManager] removeAllActions];
		selectionMask = newMask;
		[self updateSelectionSwitch];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:PXSelectionMaskChangedNotificationName object:self];
	selectedRect = NSZeroRect;
	[self updatePreviewSize];
}

- (void)setSize:(NSSize)newSize
{
	[self setSize:newSize withOrigin:NSZeroPoint backgroundColor:PXGetClearColor()];
}

- (NSSize)previewSize
{
	if (previewSize.width == 0 && previewSize.height == 0)
		return [self size];
	
	return previewSize;
}

- (void)setPreviewSize:(NSSize)size
{
	previewSize = size;
}

- (void)beginUndoGrouping
{
	[[self undoManager] beginUndoGrouping];
}

- (void)endUndoGrouping
{
    //tried to push palette change groups here, but it doesn't seem to get called during an undo or redo
	[[self undoManager] endUndoGrouping];
}

- (PXColor)eraseColor
{
	return PXGetClearColor();
}

+ (PXPalette *)frequencyPaletteForLayers:(NSArray *)layers
{
	PXPalette *palette = [[PXPalette alloc] initWithoutBackgroundColor];
	
	PXLayer *firstLayer = [layers objectAtIndex:0];
	
	CGFloat w = [firstLayer size].width;
	CGFloat h = [firstLayer size].height;
	
	for (PXLayer *current in layers)
	{
		for (CGFloat i = 0; i < w; i++)
		{
			for (CGFloat j = 0; j < h; j++)
			{
				PXColor color = [current colorAtPoint:NSMakePoint(i, j)];
				[palette incrementCountForColor:color byAmount:1];
			}
		}
	}
	
	[palette sortByFrequency];
	
	return palette;
}

@end
