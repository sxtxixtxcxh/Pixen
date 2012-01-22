//
//  PXFillTool.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXTool.h"

@interface PXFillTool : PXTool

- (void)fillPointsFromPoint:(NSPoint)aPoint forCanvasController:(PXCanvasController *)controller;
- (void)fillPixelsInBOOLArray:(NSArray *)fillPoints withColor:(PXColor)newColor withBoundsRect:(NSRect)bounds ofCanvas:(PXCanvas *)canvas;

- (BOOL)checkSelectionOnCanvas:(PXCanvas *)canvas;

@end
