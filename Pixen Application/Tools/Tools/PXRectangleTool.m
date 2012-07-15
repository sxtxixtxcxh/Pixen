//
//  PXRectangleTool.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXRectangleTool.h"
#import "PXCanvasController.h"
#import "PXPalette.h"
#import "PXShapeToolPropertiesController.h"
#import "PXCanvas_Modifying.h"

@implementation PXRectangleTool

#define SHAPE_PC ((PXShapeToolPropertiesController *) self.propertiesController)

- (NSString *)name
{
	return NSLocalizedString(@"RECTANGLE_NAME", @"Rectangle Tool");
}

-(NSString *) actionName
{
	return NSLocalizedString(@"RECTANGLE_ACTION", @"Drawing Rectangle");
}

- (PXToolPropertiesController *)createPropertiesController
{
	return [PXShapeToolPropertiesController new];
}

- (NSCursor *)cursor
{
	return [NSCursor crosshairCursor];
}

- (void)mouseDownAt:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *) controller
{
	[super mouseDownAt:aPoint fromCanvasController:controller];
	lastRect = NSMakeRect(self.origin.x, self.origin.y, 0, 0);
}

- (void)drawRect:(NSRect)aRect inCanvas:(PXCanvas *) aCanvas
{
    int i, j;
    for (i = NSMinX(aRect); i < NSMaxX(aRect); i++)
	{
		for (j = NSMinY(aRect); j < NSMaxY(aRect); j++)
		{
			[self drawPixelAtPoint:NSMakePoint(i, j) inCanvas:aCanvas];
		}
    }
}

- (void)drawFromPoint:(NSPoint)origin
			  toPoint:(NSPoint)aPoint
			 inCanvas:(PXCanvas *)canvas
		   shouldFill:(BOOL)shouldFill
{
	int borderWidth = [SHAPE_PC borderWidth];
	float leftMost = (origin.x < aPoint.x) ? origin.x : aPoint.x;
	float rightMost = (origin.x < aPoint.x) ? aPoint.x: origin.x;
	float topMost = (origin.y < aPoint.y) ? aPoint.y: origin.y;
	float bottomMost = (origin.y < aPoint.y) ? origin.y : aPoint.y;
	rightMost++;
	topMost++;
	if (rightMost - borderWidth < leftMost) {
		borderWidth = rightMost - leftMost;
	}
	if (topMost - borderWidth < bottomMost) {
		borderWidth = topMost - bottomMost;
	}
	
	if (shouldFill)
    {
		// careful about backwards-drawn rectangles...
		PXColor oldColor = [self colorForCanvas:canvas];
		
		if (![SHAPE_PC shouldUseMainColorForFill]) {
			self.color = PXColorFromNSColor([SHAPE_PC fillColor]);
		}
		
		[self drawRect:NSMakeRect(leftMost + borderWidth,
								  bottomMost + borderWidth,
								  rightMost - leftMost - 2 * borderWidth,
								  topMost - bottomMost - 2 * borderWidth)
			  inCanvas:canvas];
		
		self.color = oldColor;
    }
	
	[self drawRect:NSMakeRect(leftMost, bottomMost, rightMost - leftMost, borderWidth) inCanvas:canvas];
	[self drawRect:NSMakeRect(leftMost, topMost-borderWidth, rightMost - leftMost, borderWidth) inCanvas:canvas];
	[self drawRect:NSMakeRect(leftMost, bottomMost, borderWidth, topMost - bottomMost) inCanvas:canvas];
	[self drawRect:NSMakeRect(rightMost-borderWidth, bottomMost, borderWidth, topMost - bottomMost) inCanvas:canvas];
}

- (void)finalDrawFromPoint:(NSPoint)origin 
				   toPoint:(NSPoint)aPoint
				  inCanvas:(PXCanvas *)canvas
{
	[self drawFromPoint:origin toPoint:aPoint inCanvas:canvas shouldFill:[SHAPE_PC shouldFill]];
}

- (void)drawFromPoint:(NSPoint)origin 
			  toPoint:(NSPoint)aPoint
			 inCanvas:(PXCanvas *)canvas
{
	[super drawFromPoint:origin toPoint:aPoint inCanvas:canvas];
	[self drawFromPoint:origin toPoint:aPoint inCanvas:canvas shouldFill:NO];
}

- (void)mouseDraggedFrom:(NSPoint)initialPoint
					  to:(NSPoint)finalPoint
    fromCanvasController:(PXCanvasController *)controller
{
    NSPoint backupOrigin = self.origin;
    [super mouseDraggedFrom:initialPoint 
						 to:finalPoint
	   fromCanvasController:controller];
    self.origin = backupOrigin;
}

- (BOOL)supportsPatterns
{
	return NO;
}

@end
