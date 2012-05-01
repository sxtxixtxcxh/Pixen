//
//  PXLassoTool.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXLassoTool.h"
#import "PXCanvasController.h"
#import "PXCanvas.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXToolSwitcher.h"

@implementation PXLassoTool

- (NSString *)name
{
	return NSLocalizedString(@"LASSO_NAME", @"Lasso Tool");
}

-(id) init
{
	if (! ( self = [super init] ) ) 
		return nil;
	
	self.isClicking = NO;
	
	return self;
}

-(NSString *) actionName
{
	return NSLocalizedString(@"LASSO_ACTION", @"Selection");
}

- (NSString *) movingActionName
{
	return NSLocalizedString(@"SELECTION_MOVE_ACTION", @"Moving");
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
		[self.switcher setIcon:[NSImage imageNamed:@"lassoadd"] forTool:self];
	}
	return YES;
}

- (BOOL)shiftKeyUp
{
	if (!self.isClicking)
	{
		isAdding = NO;
		[self.switcher setIcon:[NSImage imageNamed:@"lasso"] forTool:self];
	}
	return YES;
}

- (void)drawPixelAtPoint:(NSPoint)point inCanvas:(PXCanvas *) canvas
{
	leftMost = MIN(point.x, leftMost);
	rightMost = MAX(point.x, rightMost);
	bottomMost = MIN(point.y, bottomMost);
	topMost = MAX(point.y, topMost);
	[self.path appendBezierPathWithRect:NSMakeRect(point.x, point.y, 1, 1)];
	[linePath lineToPoint:point];
}

- (void)drawRectOnTop:(NSRect)rect inView:view
{
	if (!self.isClicking || isMoving) 
	{
		return; 
	}
	
	[[[NSColor blackColor] colorWithAlphaComponent:0.7f] set];
	
	[self.path fill];
	[((isSubtracting) ? [NSColor redColor] : [NSColor whiteColor]) set];
	[self.path setLineWidth:0.1];
	[self.path stroke];
}

- (BOOL)optionKeyDown
{
	if (!self.isClicking)
	{
		isSubtracting = YES;
		[self.switcher setIcon:[NSImage imageNamed:@"lassosubtract"] forTool:self];
	}
	
	return YES;
}

- (BOOL)optionKeyUp
{
	if (!self.isClicking)
	{
		isSubtracting = NO;
		[self.switcher setIcon:[NSImage imageNamed:@"lasso"] forTool:self];
	}
	
	return YES;
}

- (void)mouseDownAt:(NSPoint)aPoint fromCanvasController:(PXCanvasController*)controller
{
	self.isClicking = YES;	
	origin = aPoint;
	leftMost = origin.x;
	rightMost = origin.x;
	bottomMost = origin.y;
	topMost = origin.y;
	
	//have to have an undo grouping here because we're doing multiple selects on the canvas, including the deselect.
	[[controller canvas] beginUndoGrouping];
	if ( ([[controller canvas] pointIsSelected:aPoint] )
		 && (!isAdding && !isSubtracting) )
	{
		[self startMovingCanvas:[controller canvas]];
	}
	else
	{
		if (!isAdding && !isSubtracting)
		{
			[[controller canvas] deselect];
		}
		
		self.path = [NSBezierPath bezierPath];
		[self.path appendBezierPathWithRect:NSMakeRect(aPoint.x, aPoint.y, 1, 1)];
		[linePath release];
		linePath = [[NSBezierPath bezierPath] retain];
		[linePath moveToPoint:origin];
	}
}

- (void)startMovingCanvas:(PXCanvas *)canvas
{
	isMoving = YES;
	selectedRect = [canvas selectedRect];
	lastSelectedRect = NSZeroRect;
}

- (void)stopMovingCanvas:canvas
{
	isMoving = NO;
}

- (void)mouseDraggedFrom:(NSPoint)initialPoint 
					  to:(NSPoint)finalPoint 
	fromCanvasController:(PXCanvasController *) controller
{
	NSPoint differencePoint = NSMakePoint(finalPoint.x - initialPoint.x, finalPoint.y - initialPoint.y);
	
	NSPoint currentPoint = initialPoint;
	
	if (isMoving)
	{
		[[controller canvas] translateSelectionMaskByX:differencePoint.x y:differencePoint.y];
		selectedRect.origin.x += differencePoint.x;
		selectedRect.origin.y += differencePoint.y;
		[[controller canvas] changedInRect:NSInsetRect(NSUnionRect(selectedRect, lastSelectedRect), -1, -1)];
		lastSelectedRect = selectedRect;
	}
	else
	{
		while(!NSEqualPoints(finalPoint, currentPoint))
		{
			if(differencePoint.x == 0) 
			{
				currentPoint.y += ((differencePoint.y > 0) ? 1 : -1); 
			}
			else if (differencePoint.y == 0) 
			{ 
				currentPoint.x += ((differencePoint.x > 0) ? 1 : -1); 
			}
			else if(abs(differencePoint.x) < abs(differencePoint.y)) 
			{
				currentPoint.y += ((differencePoint.y > 0) ? 1 : -1);
				currentPoint.x = rintf((differencePoint.x/differencePoint.y)*(currentPoint.y-initialPoint.y) + initialPoint.x);
			} 
			else
			{
				currentPoint.x += ((differencePoint.x > 0) ? 1 : -1);
				currentPoint.y = rintf((differencePoint.y/differencePoint.x)*(currentPoint.x-initialPoint.x) + initialPoint.y);
			}
			
			if(NSPointInRect(currentPoint, NSMakeRect(0, 0, [[controller canvas] size].width, [[controller canvas] size].height)))
			{
				[self drawPixelAtPoint:currentPoint inCanvas:[controller canvas]];
			}
		}
		
		[[controller canvas] changedInRect:[self.path bounds]];
	}
}

- (void)mouseUpAt:(NSPoint)aPoint fromCanvasController:(PXCanvasController *)controller
{
	PXCanvas *canvas = [controller canvas];
	self.isClicking = NO;
	if (!isMoving)
	{
		NSMutableArray *indices = [NSMutableArray arrayWithCapacity:1000];
		[linePath closePath];
		int i, j;
		//go from left to right
		for (i = leftMost; i <= rightMost; i++)
		{
			//go from bottom to top
			for (j = bottomMost; j <= topMost; j++)
			{
				NSPoint point = NSMakePoint(i, j);
				if([linePath containsPoint:point])
				{
					[indices addObject:[NSNumber numberWithInt:point.x + ([canvas size].height - point.y - 1) * [canvas size].width]];
				}
			}
		}
		[canvas setSelectionMaskBit:!isSubtracting atIndices:indices];		
		[canvas changedInRect:NSMakeRect(leftMost-8, bottomMost-8, rightMost-leftMost+16, topMost-bottomMost+16)];
	}
	else
	{
		[self stopMovingCanvas:canvas];
		if (NSEqualPoints(origin, aPoint))
		{
			[canvas deselect];
		}
		else
		{	
			[canvas finalizeSelectionMotion];
		}
	}
	[canvas endUndoGrouping:NSLocalizedString(@"Selection", @"Selection")];
	[canvas updateSelectionSwitch];
}

@end
