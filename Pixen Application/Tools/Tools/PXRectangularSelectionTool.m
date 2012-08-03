//
//  PXRectangularSelectionTool.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXRectangularSelectionTool.h"
#import "PXCanvasController.h"
#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Selection.h"
#import "PXCanvasView.h"
#import "PXLayer.h"
#import "PXToolSwitcher.h"

@implementation PXRectangularSelectionTool

- (NSString *)name
{
	return NSLocalizedString(@"RECTANGULARSELECTION_NAME", @"Rectangular Selection Tool");
}

- (NSCursor *)cursor
{
	return [NSCursor crosshairCursor];
}

- (BOOL)shiftKeyDown
{
	if (!self.isClicking)
	{
		isAdding = YES;
		[self.switcher setIcon:[NSImage imageNamed:@"squareselectadd"] forTool:self];
	}
	return YES;
}

- (BOOL)shiftKeyUp
{
	if (!self.isClicking)
	{
		isAdding = NO;
		[self.switcher setIcon:[NSImage imageNamed:@"squareselect"] forTool:self];
	}
	return YES;
}

- (BOOL)optionKeyDown
{
	if (!self.isClicking)
	{
		isSubtracting = YES;
		[self.switcher setIcon:[NSImage imageNamed:@"squareselectsubtract"] forTool:self];
	}
	return YES;
}

- (BOOL)optionKeyUp
{
	if (!self.isClicking)
	{
		isSubtracting = NO;
		[self.switcher setIcon:[NSImage imageNamed:@"squareselect"] forTool:self];
	}
	return YES;
}

- (void)mouseDownAt:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *) controller
{
	origin = aPoint;
	self.isClicking = YES;
	
	//have to have an undo grouping here because we're doing multiple selects on the canvas.
	[[controller canvas] beginUndoGrouping];
	if ( ( [[controller canvas] pointIsSelected:aPoint] ) 
		 && (!isAdding && !isSubtracting) ) 
	{
		lastSelectedRect = [[controller canvas] selectedRect];
		[self startMovingCanvas:[controller canvas]];
	}
	else
	{
		selectedRect = NSZeroRect;
		lastSelectedRect = NSZeroRect;
		if (!isAdding && !isSubtracting) { [[controller canvas] deselect]; }
	}
}

- (void)startMovingCanvas:(PXCanvas *)canvas
{
	isMoving = YES;
	selectedRect = [canvas selectedRect]; 
}

- (void)stopMovingCanvas:(PXCanvas *)canvas
{
	isMoving = NO;
	selectedRect = lastSelectedRect; 
}

- (void)refreshRect:(NSRect)rectangle inView:view
{
	NSRect modifiedRect = rectangle;
	modifiedRect.origin.x -= 1;
	modifiedRect.origin.y -= 1;
	modifiedRect.size.width += 2;
	modifiedRect.size.height += 2;
	[view displayRect:[view convertFromCanvasToViewRect:modifiedRect]];
}

- (void)drawRectOnTop:(NSRect)rect inView:(PXCanvasView *)view
{
	// selection drawing (while still dragging) is now O(1). hooray.
	if (!self.isClicking || isMoving) { return; }
	NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRect:selectedRect];
	[bezierPath setLineWidth:1.0f/([[view transform] transformSize:NSMakeSize(1,1)].width)];
	CGFloat patternLength = 17.5f/([[view transform] transformSize:NSMakeSize(5,1)].width);
	const CGFloat pattern[] = { patternLength, patternLength };
	[[NSColor whiteColor] set];
	[bezierPath setLineDash:pattern count:1 phase:0];
	[bezierPath stroke];
	if (isSubtracting)
		[[NSColor redColor] set];
	else
		[[NSColor blackColor] set];
	[bezierPath setLineDash:pattern count:1 phase:patternLength];
	[bezierPath stroke];
}


- (void)mouseDraggedFrom:(NSPoint)initialPoint
					  to:(NSPoint)finalPoint
	fromCanvasController:(PXCanvasController *)controller
{
	if (isMoving)
	{
		int xOffset = finalPoint.x - initialPoint.x;
		int yOffset = finalPoint.y - initialPoint.y;
		[[controller canvas] translateSelectionMaskByX:xOffset y:yOffset];
		selectedRect.origin.x += xOffset;
		selectedRect.origin.y += yOffset;
	}
	else
	{
		selectedRect = NSUnionRect(NSMakeRect(origin.x, origin.y, 1, 1), NSMakeRect(finalPoint.x, finalPoint.y, 1, 1));
	}
	[[controller canvas] changedInRect:NSInsetRect(NSUnionRect(selectedRect, lastSelectedRect), -1, -1)];
	lastSelectedRect = selectedRect;
}

- (void)mouseUpAt:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *)controller
{
	if(isMoving)
	{
		[self stopMovingCanvas:[controller canvas]];
		if (!NSEqualPoints(origin, aPoint))
		{
			[[controller canvas] finalizeSelectionMotion];
		}
	}
	else if (NSEqualPoints(origin, aPoint))
	{
		[[controller canvas] deselect];
	}
	else
	{
		for (NSString *current in [[controller canvas] boundedRectsFromRect: selectedRect])
		{
			if (isSubtracting) {
				[[controller canvas] deselectPixelsInRect:NSRectFromString(current)];
				[[controller canvas] changed];
			} else {
				[[controller canvas] selectPixelsInRect:NSRectFromString(current)];
			}
		}
	}
	[[controller canvas] endUndoGrouping:NSLocalizedString(@"Selection", @"Selection")];
	self.isClicking = NO;
	[[controller canvas] changedInRect:[[controller canvas] selectedRect]];
	selectedRect = NSZeroRect;
}

@end
