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

@implementation PXCanvas

@synthesize tempLayers, grid;

- (id)copyWithZone:(NSZone *)zone
{
	return [[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]] retain];
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
	
	layers = [[NSMutableArray alloc] initWithCapacity:23];
	grid = [[PXGrid alloc] init];
	bgConfig = [[PXBackgroundConfig alloc] init];
	
	return self;
}

- (void)dealloc
{
	if (selectionMask)
		free(selectionMask);
	
	[tempLayers release];
	[layers release];
	[bgConfig release];
	[grid release];
	
	[_drawnPoints release];
	PXColorArrayRelease(_oldColors);
	PXColorArrayRelease(_newColors);
	
	[_minusColors release];
	[_plusColors release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void)setUndoManager:(NSUndoManager *)manager
{
	undoManager = manager;
	[undoManager setGroupsByEvent:NO];
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

- (void)endColorUpdates
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PXCanvasPaletteUpdate"
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																(id) _minusColors, @"PXCanvasPaletteUpdateRemoved",
																(id) _plusColors, @"PXCanvasPaletteUpdateAdded", nil]];
	
	[_minusColors removeAllObjects];
	[_plusColors removeAllObjects];
}

- (void)reallyRefreshWholePalette
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PXCanvasFrequencyPaletteRefresh"
														object:self
													  userInfo:nil];
	
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
			
			[self setLayersNoResize:[[layers deepMutableCopy] autorelease] fromLayers:layers];
			for (PXLayer *current in layers)
			{
				[current setSize:newSize withOrigin:origin backgroundColor:color];
			}
			[self setMaskData:newData withOldMaskData:oldData];
        //NSLog(@"Mask data updated - copied %@", [[layers lastObject] name]);
			free(newMask);
      [self refreshWholePalette];
		} [self endUndoGrouping:NSLocalizedString(@"Change Canvas Size", @"Change Canvas Size")];
	}
	else 
	{
		[self insertLayer:[[[PXLayer alloc] initWithName:NSLocalizedString(@"Main Layer", @"Main Layer")
													size:newSize
										   fillWithColor:color] autorelease] atIndex:0];
		
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

- (void)endUndoGrouping:(NSString *)action
{
	[[self undoManager] setActionName:action];
	[self endUndoGrouping];
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
	
	NSCountedSet *colors = [NSCountedSet set];
	
	for (PXLayer *current in layers)
	{
		for (CGFloat i = 0; i < w; i++)
		{
			for (CGFloat j = 0; j < h; j++)
			{
				PXColor color = [current colorAtPoint:NSMakePoint(i, j)];
				[colors addObject:PXColorToNSColor(color)];
			}
		}
	}
	
	for (NSColor *color in colors)
	{
		[palette incrementCountForColor:PXColorFromNSColor(color) byAmount:[colors countForObject:color]];
	}
	
	return [palette autorelease];
}

@end
