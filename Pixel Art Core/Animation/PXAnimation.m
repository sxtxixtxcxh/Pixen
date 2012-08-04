//
//  PXAnimation.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXAnimation.h"

#import "PXCel.h"
#import "PXCanvas.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXPalette.h"
#import "NSMutableArray+ReorderingAdditions.h"

#import "gif_lib.h"

@implementation PXAnimation

@synthesize undoManager;

- (id)init
{
	self = [super init];
	cels = [[NSMutableArray alloc] initWithCapacity:100];
	[cels addObject:[[PXCel alloc] init]];
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	PXAnimation *newAnimation = [[PXAnimation alloc] init];
	[newAnimation setValue:[cels deepMutableCopy] forKey:@"cels"];
	[newAnimation setUndoManager:undoManager];
	return newAnimation;
}

- (PXCel *)celAtIndex:(NSUInteger)index 
{
	return [cels objectAtIndex:index];
}

- (NSUInteger)indexOfObjectInCels:(PXCel *)cel
{
	return [cels indexOfObject:cel];
}

- (NSUInteger)countOfCels
{
	return [cels count];
}

- (NSArray *)canvases
{
  return [cels valueForKey:@"canvas"];
}

- (PXPalette *)newFrequencyPaletteForAllCels
{
	PXPalette *palette = [[PXPalette alloc] initWithoutBackgroundColor];
	
	CGFloat w = [self size].width;
	CGFloat h = [self size].height;
	
	for (PXCel *cel in cels)
	{
		PXCanvas *canvas = [cel canvas];
		
		for (CGFloat i = 0; i < w; i++)
		{
			for (CGFloat j = 0; j < h; j++)
			{
				PXColor color = [canvas mergedColorAtPoint:NSMakePoint(i, j)];
				[palette incrementCountForColor:color byAmount:1];
			}
		}
	}
	
	return palette;
}

- (NSSize)size
{
	return [[cels lastObject] size];
}

- (void)setSizeNoUndo:(NSSize)aSize
{
	for (PXCel *current in cels)
	{
		[current setSize:aSize];
	}
}

- (void)setSize:(NSSize)aSize
{
	[self setSize:aSize withOrigin:NSZeroPoint backgroundColor:PXGetClearColor()];
}

- (void)_willChangeSize:(BOOL)undo
{
	[self willChangeValueForKey:@"size"];
	if(undo)
	{
		[[undoManager prepareWithInvocationTarget:self] _willChangeSize:undo];
	}
}

- (void)_didChangeSize:(BOOL)undo
{
	[self didChangeValueForKey:@"size"];
	if(undo)
	{
		[[undoManager prepareWithInvocationTarget:self] _didChangeSize:undo];
	}
}

- (void)setSize:(NSSize)aSize withOrigin:(NSPoint)origin backgroundColor:(PXColor)color
{
	[self setSize:aSize withOrigin:origin backgroundColor:color undo:YES];
}

- (void)setSize:(NSSize)aSize withOrigin:(NSPoint)origin backgroundColor:(PXColor)color undo:(BOOL)undo
{
	if (undo) {
		[undoManager beginUndoGrouping];
	}
	
	[self _willChangeSize:undo];
	
	for (PXCel *currentCel in cels) {
		[currentCel setSize:aSize withOrigin:origin backgroundColor:color];
	}
	
	[self _didChangeSize:undo];
	
	if (undo) {
		[undoManager endUndoGrouping];
	}
}

- (void)setUndoManager:(NSUndoManager *)man
{
	if (undoManager != man) {
		undoManager = man;
		
		[cels setValue:man forKey:@"undoManager"];
	}
}

- (void)insertObject:(PXCel *)cel inCelsAtIndex:(NSUInteger)index
{
	[self willChangeValueForKey:@"countOfCels"];
	[undoManager beginUndoGrouping];
	[[undoManager prepareWithInvocationTarget:self] removeCel:cel];
	[cel setUndoManager:undoManager];
  NSSize oldSize = [self size];
	[cels insertObject:cel atIndex:index];
  if(!NSEqualSizes([cel size], oldSize))
  {
    NSSize resultSize = oldSize;
    if([cel size].width > resultSize.width) 
    {
      resultSize.width = [cel size].width;
    }
    if([cel size].height > resultSize.height) 
    {
      resultSize.height = [cel size].height;
    }
    [self setSize:resultSize];
  }
	[undoManager endUndoGrouping];
	[self didChangeValueForKey:@"countOfCels"];
}

- (void)addCel:(PXCel *)cel
{
	[self insertObject:cel inCelsAtIndex:[self countOfCels]];
}

- (void)insertNewCelAtIndex:(NSUInteger)index
{
	PXCel *newCel = [[PXCel alloc] init];
	[newCel setSize:[self size]];
	if(index <= [cels count] && index > 0)
	{
		[[newCel canvas] setGrid:[[[cels objectAtIndex:index - 1] canvas] grid]];
	}
	[self insertObject:newCel inCelsAtIndex:index];	
}

- (void)addNewCel
{
	[self insertNewCelAtIndex:0];
}

- (void)moveCelFromIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2
{
	if(index1 == index2) { return; }
	[self willChangeValueForKey:@"countOfCels"];
	[undoManager beginUndoGrouping];
	PXCel *cel = [cels objectAtIndex:index1];
	[cels insertObject:cel atIndex:index2];
	NSUInteger removeIndex = index1;
	if(index1 > index2)
	{
		removeIndex++;
	}
	[cels removeObjectAtIndex:removeIndex];
	[[undoManager prepareWithInvocationTarget:self] moveCelFromIndex:[cels indexOfObject:cel] toIndex:removeIndex];
	[undoManager setActionName:NSLocalizedString(@"Move Cel", @"Move Cel")];
	[undoManager endUndoGrouping];
	[self didChangeValueForKey:@"countOfCels"];
}

- (void)copyCelFromIndex:(NSUInteger)originalIndex toIndex:(NSUInteger)insertionIndex
{
	[self willChangeValueForKey:@"countOfCels"];
	[undoManager beginUndoGrouping];
	PXCel *cel = [[self celAtIndex:originalIndex] copy];
	[cel setUndoManager:undoManager];
	[[undoManager prepareWithInvocationTarget:self] removeCel:cel];
	[cels insertObject:cel atIndex:insertionIndex];
	[undoManager endUndoGrouping];
	[self didChangeValueForKey:@"countOfCels"];
}

- (void)removeObjectFromCelsAtIndex:(NSUInteger)index
{
	[self willChangeValueForKey:@"countOfCels"];
	[undoManager beginUndoGrouping];
	[[undoManager prepareWithInvocationTarget:self] insertObject:[self celAtIndex:index] inCelsAtIndex:index];
	[cels removeObjectAtIndex:index];
	[undoManager endUndoGrouping];
	[self didChangeValueForKey:@"countOfCels"];
}

- (void)removeCel:(PXCel *)cel
{
	[self removeObjectFromCelsAtIndex:[cels indexOfObject:cel]];
}

- (NSBitmapImageRep *)spriteSheetWithCelMargin:(int)margin
{
	int fullWidth = [self countOfCels]*[self size].width + ([self countOfCels] - 1)*margin;
	int width = fullWidth; //could change this if multirow sheets were desirable.  they're not.
	int cellsHigh = (int)(ceilf((float)fullWidth/(float)width));
	NSSize imageSize = NSMakeSize(MIN(fullWidth, width), cellsHigh*[self size].height + (cellsHigh - 1)*margin);
	
	NSBitmapImageRep *spriteSheet = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																			pixelsWide:imageSize.width
																			pixelsHigh:imageSize.height
																		 bitsPerSample:8
																	   samplesPerPixel:4
																			  hasAlpha:YES
																			  isPlanar:NO
																		colorSpaceName:NSCalibratedRGBColorSpace
																		   bytesPerRow:0
																		  bitsPerPixel:32];
	
	NSPoint compositePoint = NSMakePoint(0, imageSize.height - [self size].height);
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:spriteSheet]];
	
	for (PXCel *cel in cels) {
		[[cel.canvas imageRep] drawInRect:NSMakeRect(compositePoint.x, compositePoint.y, [cel size].width, [cel size].height)
								 fromRect:NSZeroRect
								operation:NSCompositeSourceOver
								 fraction:1.0f
						   respectFlipped:NO
									hints:nil];
		
		compositePoint.x += [cel size].width + margin;
		
		if (compositePoint.x + [cel size].width > imageSize.width) {
			compositePoint.x = 0;
			compositePoint.y += [cel size].height + margin;
		}
	}
	
	[NSGraphicsContext restoreGraphicsState];
	
	return spriteSheet;
}

- (void)reduceColorsTo:(int)colors withTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor
{
	[PXCanvas reduceColorsInCanvases:[cels valueForKey:@"canvas"]
						toColorCount:colors
					withTransparency:transparency
						  matteColor:matteColor];
}

@end
