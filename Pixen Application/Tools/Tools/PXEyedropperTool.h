//
//  PXEyedropperTool.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXTool.h"

@interface PXEyedropperTool : PXTool

- (PXColor)compositeColorAtPoint:(NSPoint)aPoint fromCanvas:(PXCanvas *)canvas;

- (void)mouseDownAt:(NSPoint)aPoint fromCanvasController:(PXCanvasController *)controller;

- (void)mouseDraggedFrom:(NSPoint)initialPoint
					  to:(NSPoint)finalPoint
    fromCanvasController:(PXCanvasController *)controller;

- (void)mouseUpAt:(NSPoint)aPoint fromCanvasController:(PXCanvasController *)controller;

@end
