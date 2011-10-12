//
//  PXFillTool.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXTool.h"

@interface PXFillTool : PXTool

- (void)fillPointsFromPoint:(NSPoint)aPoint forCanvasController:(PXCanvasController *)controller;
- (void)fillPixelsInBOOLArray:(NSArray *)fillPoints withColor:(NSColor *)newColor withBoundsRect:(NSRect)bounds ofCanvas:(PXCanvas *)canvas;

- (BOOL)checkSelectionOnCanvas:(PXCanvas *)canvas;

@end
