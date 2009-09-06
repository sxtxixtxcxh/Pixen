//
//  PXAnimation.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "PXAnimation.h"
#import "PXCel.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "NSMutableArray+ReorderingAdditions.h"

#import "gif_lib.h"

@implementation PXAnimation

- init
{
	[super init];
	cels = [[NSMutableArray alloc] initWithCapacity:100];
	[cels addObject:[[[PXCel alloc] init] autorelease]];
	palette = PXPalette_init(PXPalette_alloc());
	[self setPalette:palette];
	return self;
}

- (void)dealloc
{
	[cels release];
	PXPalette_release(palette);
	[super dealloc];
}

- copyWithZone:(NSZone *)zone
{
	PXAnimation *newAnimation = [[PXAnimation alloc] init];
	[newAnimation setValue:[cels deepMutableCopy] forKey:@"cels"];
	PXPalette *paletteCopy = PXPalette_copy(palette);
	[newAnimation setPalette:paletteCopy recache:NO];
	[newAnimation setUndoManager:undoManager];
	return newAnimation;
}

- (PXCel *)objectInCelsAtIndex:(unsigned int)index 
{
	return [cels objectAtIndex:index];
}

- (unsigned int)indexOfObjectInCels:(PXCel *)cel
{
	return [cels indexOfObject:cel];
}

- (unsigned int)countOfCels
{
	return [cels count];
}

- (NSSize)size
{
	return [[cels lastObject] size];
}

- (PXPalette *)palette
{
	return palette;
}

- (void)setPalette:(PXPalette *)pal recache:(BOOL)recache
{
	PXPalette_retain(pal);
	PXPalette_release(palette);
	palette = pal;
	id enumerator = [cels objectEnumerator], current;
	while(current = [enumerator nextObject])
	{
		[current setPalette:palette recache:recache];
	}
}

- (void)setPalette:(PXPalette *)pal
{
	[self setPalette:pal recache:YES];
}

- (void)setSizeNoUndo:(NSSize)aSize
{
	id enumerator = [cels objectEnumerator], current;
	while(current = [enumerator nextObject])
	{
		[current setSize:aSize];
	}
}

- (void)setSize:(NSSize)aSize
{
	[self setSize:aSize withOrigin:NSZeroPoint backgroundColor:[NSColor clearColor]];
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

- (void)setSize:(NSSize)aSize withOrigin:(NSPoint)origin backgroundColor:(NSColor *)bgcolor
{
	[self setSize:aSize withOrigin:origin backgroundColor:bgcolor undo:YES];
}

- (void)setSize:(NSSize)aSize withOrigin:(NSPoint)origin backgroundColor:(NSColor *)bgcolor undo:(BOOL)undo
{
	if(undo)
	{
		[undoManager beginUndoGrouping];
	}
	[self _willChangeSize:undo];
	id enumerator = [cels objectEnumerator], current;
	while(current = [enumerator nextObject])
	{
		[current setSize:aSize withOrigin:origin backgroundColor:bgcolor];
	}
	[self _didChangeSize:undo];
	if(undo)
	{
		[undoManager endUndoGrouping];
	}
}

- (NSUndoManager *)undoManager
{
	return undoManager;
}

- (void)setUndoManager:man
{
	undoManager = man;
	[undoManager setGroupsByEvent:NO];
	[cels setValue:man forKey:@"undoManager"];
}

- (void)insertObject:(PXCel *)cel inCelsAtIndex:(unsigned int)index
{
	[self willChangeValueForKey:@"countOfCels"];
	[undoManager beginUndoGrouping];
	[[undoManager prepareWithInvocationTarget:self] removeCel:cel];
	[cel setUndoManager:undoManager];
	[cel setPalette:palette];
	[cels insertObject:cel atIndex:index];
	[undoManager setActionName:NSLocalizedString(@"Add Cel", @"Add Cel")];
	[undoManager endUndoGrouping];
	[self didChangeValueForKey:@"countOfCels"];
}

- (void)addCel:(PXCel *)cel
{
	[self insertObject:cel inCelsAtIndex:[self countOfCels]];
}

- (void)insertNewCelAtIndex:(unsigned int)index
{
	PXCel *newCel = [[[PXCel alloc] init] autorelease];
	[newCel setSize:[self size]];
	[newCel setPalette:palette];
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

- (void)moveCelFromIndex:(int)index1 toIndex:(int)index2
{
	if(index1 == index2) { return; }
	[self willChangeValueForKey:@"countOfCels"];
	[undoManager beginUndoGrouping];
	id cel = [cels objectAtIndex:index1];
	[cels insertObject:cel atIndex:index2];
	int removeIndex = index1;
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

- (void)copyCelFromIndex:(int)originalIndex toIndex:(int)insertionIndex
{
	[self willChangeValueForKey:@"countOfCels"];
	[undoManager beginUndoGrouping];
	PXCel *cel = [[[self objectInCelsAtIndex:originalIndex] copy] autorelease];
	[cel setUndoManager:undoManager];
	[cel setPalette:palette];
	[[undoManager prepareWithInvocationTarget:self] removeCel:cel];
	[cels insertObject:cel atIndex:insertionIndex];
	[undoManager setActionName:NSLocalizedString(@"Copy Cel", @"Copy Cel")];
	[undoManager endUndoGrouping];
	[self didChangeValueForKey:@"countOfCels"];
}

- (void)removeObjectFromCelsAtIndex:(unsigned int)index
{
	[self willChangeValueForKey:@"countOfCels"];
	[undoManager beginUndoGrouping];
	[[undoManager prepareWithInvocationTarget:self] insertObject:[self objectInCelsAtIndex:index] inCelsAtIndex:index];
	[cels removeObjectAtIndex:index];
	[undoManager setActionName:NSLocalizedString(@"Delete Cel", @"Delete Cel")];
	[undoManager endUndoGrouping];
	[self didChangeValueForKey:@"countOfCels"];
}

- (void)removeCel:(PXCel *)cel
{
	[self removeObjectFromCelsAtIndex:[cels indexOfObject:cel]];
}

- (NSImage *)spriteSheetWithinWidth:(int)width celMargin:(int)margin
{
	int fullWidth = [self countOfCels]*[self size].width + ([self countOfCels] - 1)*margin;
	int cellsHigh = (fullWidth/width + 1);
	NSSize imageSize = NSMakeSize(MIN(fullWidth, width), cellsHigh*[self size].height + (cellsHigh - 1)*margin);
	NSImage *spriteSheet = [[[NSImage alloc] initWithSize:imageSize] autorelease];
	NSPoint compositePoint = NSMakePoint(0, imageSize.height - [self size].height);
	int i;
	[spriteSheet lockFocus];
	for (i=0; i<[self countOfCels]; i++) {
		[[[self objectInCelsAtIndex:i] displayImage] compositeToPoint:compositePoint operation:NSCompositeCopy];
		compositePoint.x += [self size].width + margin;
		if (compositePoint.x + [self size].width > imageSize.width) {
			compositePoint.x = 0;
			compositePoint.y -= [self size].height + margin;
		}
	}
	[spriteSheet unlockFocus];
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
