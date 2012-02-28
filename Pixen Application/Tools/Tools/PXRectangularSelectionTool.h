//
//  PXRectangularSelectionTool.h
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXTool.h"
#import "PXCanvas.h"

@interface PXRectangularSelectionTool : PXTool 
{
  @private
	NSPoint origin;
	NSRect selectedRect, lastSelectedRect;
	BOOL isMoving;
	BOOL isAdding;
	BOOL isSubtracting;
}

- (void)mouseDownAt:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *)controller;

- (void)mouseDraggedFrom:(NSPoint)origin
					  to:(NSPoint)destination
    fromCanvasController:(PXCanvasController *)controller;

- (void)startMovingCanvas:(PXCanvas *) canvas;

- (void)stopMovingCanvas:(PXCanvas *)canvas;

@end
