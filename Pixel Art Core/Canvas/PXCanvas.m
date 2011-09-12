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

@interface PXFrequencyEntry : NSObject
{
	int count;
	NSColor *color;
}
+ withColor:c;
- initWithColor:c;
- (int)count;
- (NSColor *)color;
- (void)increment;
@end
@implementation PXFrequencyEntry

+ (id)withColor:(NSColor *)c
{
	return [[[self alloc] initWithColor:c] autorelease];
}

- (id)initWithColor:(NSColor *)c
{
	self = [super init];
	count = 1;
	color = [c retain];
	return self;
}

- (void)dealloc
{
	[color release];
	[super dealloc];
}

- (int)count
{
	return count;
}

- (NSColor *)color
{
	return color;
}

- (void)increment
{
	count++;
}

- (NSComparisonResult)compare:(PXFrequencyEntry *)other
{
	return count < [other count];
}

@end


@implementation PXCanvas

@synthesize tempLayers, grid;

-(id)copyWithZone:(NSZone*) zone
{
	return [[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]] retain];
}

- (id)_rawInit
{
	if (![super init]) return nil;
  plusColors = [[NSCountedSet alloc] init];
  minusColors = [[NSCountedSet alloc] init];
  frequencyPaletteDirty = NO;
	return self;
}

- (void)recacheSize
{
	canvasRect = NSMakeRect(0, 0, [self size].width, [self size].height);
}

- (id)init
{
	if ( ! (self = [super init]))
		return nil;
	
	plusColors = [[NSCountedSet alloc] init];
	minusColors = [[NSCountedSet alloc] init];
	frequencyPaletteDirty = NO;
	layers = [[NSMutableArray alloc] initWithCapacity:23];
	grid = [[PXGrid alloc] init];
	bgConfig = [[PXBackgroundConfig alloc] init];
	wraps = NO;
	drawnPoints = nil;
	oldColors = nil;
	newColors = nil;
	return self;
}

- (void)dealloc
{
	if (selectionMask)
	{
		free(selectionMask);
	}
	
	[tempLayers release];
	[drawnPoints release];
	[oldColors release];
	[newColors release];
	[layers release];
	[bgConfig release];
  [minusColors release];
  [plusColors release];
	[grid release];
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
	[self layersChanged];
}

- (void)clearIncrementalPaletteRefresh
{
	[minusColors removeAllObjects];
	[plusColors removeAllObjects];
}

//could be coalesced by timer or update/undo group; would rather do it with undo.
- (void)reallyRefreshWholePalette:ignored
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PXCanvasFrequencyPaletteRefresh" object:self userInfo:nil];
	frequencyPaletteDirty = NO;
	[self clearIncrementalPaletteRefresh];
}

- (void)reallyRefreshIncrementalPalette:ignored
{
	// NSLog(@"incremental update");
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PXCanvasPaletteUpdate"
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:minusColors, @"PXCanvasPaletteUpdateRemoved", plusColors, @"PXCanvasPaletteUpdateAdded", nil]];
	[self clearIncrementalPaletteRefresh];
}

- (void)refreshWholePalette
{
	if (!frequencyPaletteDirty)
	{
		frequencyPaletteDirty = YES;
		
		[[self class] cancelPreviousPerformRequestsWithTarget:self];
		[self performSelector:@selector(reallyRefreshWholePalette:) withObject:nil afterDelay:0.5f];
	}
}

- (void)refreshPaletteDecreaseColorCount:(NSColor *)down increaseColorCount:(NSColor *)up
{
	if ([down isEqual:up])
		return;
	
	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(reallyRefreshIncrementalPalette:) object:nil];
	
	[minusColors addObject:down];
	[plusColors addObject:up];
	
	[self performSelector:@selector(reallyRefreshIncrementalPalette:) withObject:nil afterDelay:0.5f];
}

- (void)setSize:(NSSize)aSize 
	 withOrigin:(NSPoint)origin
backgroundColor:(NSColor *)color
{
	unsigned newMaskLength = sizeof(BOOL) * aSize.width * aSize.height;
	PXSelectionMask newMask = calloc(aSize.width * aSize.height, sizeof(BOOL));
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
				[current setSize:aSize withOrigin:origin backgroundColor:color];
			}
			[self setMaskData:newData withOldMaskData:oldData];
        //NSLog(@"Mask data updated - copied %@", [[layers lastObject] name]);
			free(newMask);
      [self refreshWholePalette];
		} [self endUndoGrouping:NSLocalizedString(@"Change Canvas Size", @"Change Canvas Size")];
	}
	else 
	{
		[self insertLayer:[[[PXLayer alloc] initWithName:NSLocalizedString(@"Main Layer", @"Main Layer") size:aSize fillWithColor:color] autorelease] atIndex:0];
    [self reallyRefreshWholePalette:nil];
		[self activateLayer:[layers objectAtIndex:0]];
		[[self undoManager] removeAllActions];
		selectionMask = newMask;
		[self updateSelectionSwitch];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:PXSelectionMaskChangedNotificationName object:self];
	selectedRect = NSZeroRect;
	[self updatePreviewSize];
}

- (void)setSize:(NSSize)aSize
{
	NSColor *color = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0];
	
	[self setSize:aSize
	   withOrigin:NSZeroPoint 
  backgroundColor:color];
}

- (NSSize)previewSize
{
	if (previewSize.width == 0 && previewSize.height == 0)
		return [self size];
	
	return previewSize;
}

- (void)setPreviewSize:(NSSize)aSize
{
	previewSize = aSize;
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

- (NSColor *)eraseColor
{
	if([layers count] > 0)
	{
		return PXImage_backgroundColor([(PXLayer *)[layers objectAtIndex:0] image]);
	}
	return [[NSColor clearColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
}

- (PXPalette *)newFrequencyPalette
{
	PXPalette *freqPal = [[PXPalette alloc] initWithoutBackgroundColor];
	NSSize sz = [self size];
	float w = sz.width;
	float h = sz.height;
	NSCountedSet *colors = [NSCountedSet set];
	for (PXLayer * current in layers)
	{
		int i;
		for (i = 0; i < w; i++)
		{
			int j;
			for (j = 0; j < h; j++)
			{
				NSColor *color = [current colorAtPoint:NSMakePoint(i, j)];
				[colors addObject:color];
			}
		}
	}
	for(NSColor *c in colors)
	{
		[freqPal incrementCountForColor:c byAmount:[colors countForObject:c]];
	}
	return freqPal;
}

@end
