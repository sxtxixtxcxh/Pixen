//
//  PXPencilTool.h
//  Pixen
//
//  Copyright 2003-2012 Pixen Project. All rights reserved.
//

#import "PXTool.h"

@class PXCanvas, PXLayer;

@interface PXPencilTool : PXTool 
{
  @private
	BOOL isDragging;
	BOOL shiftDown;
	NSRect changedRect, lastBezierBounds;
	NSPoint movingOrigin;
  @public
	BOOL shouldUseBezierDrawing;
}

- (BOOL)shouldUseBezierDrawing;

- (void)mouseDownAt:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *)controller;

- (void)mouseDraggedFrom:(NSPoint)origin
					  to:(NSPoint)destination
    fromCanvasController:(PXCanvasController *)controller;

- (void)mouseUpAt:(NSPoint)point
fromCanvasController:(PXCanvasController *)controller;

- (void)drawWithOldColor:(PXColor)oldColor
				newColor:(PXColor)newColor
				 atPoint:(NSPoint)aPoint
				 inLayer:(PXLayer *)aLayer
				ofCanvas:(PXCanvas *)aCanvas;

- (void)drawPixelAtPoint:(NSPoint)aPoint
				inCanvas:(PXCanvas *)aCanvas;

- (void)drawLineFrom:(NSPoint)initialPoint
				  to:(NSPoint)finalPoint
			inCanvas:(PXCanvas *)canvas;

@end
