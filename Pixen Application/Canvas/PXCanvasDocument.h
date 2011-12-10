//
//  PXCanvasDocument.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXDocument.h"

@class PXCanvas, PXCanvasController, PXCanvasPrintView;

@interface PXCanvasDocument : PXDocument
{
	PXCanvasPrintView *_printableView;
    PXCanvas *_canvas;
}

@property (nonatomic, retain) PXCanvas *canvas;

+ (NSData *)dataRepresentationOfType:(NSString *)aType withCanvas:(PXCanvas *)canvas;
- (void)loadFromPasteboard:(NSPasteboard *)board;

- (PXCanvasController *)canvasController;

@end
