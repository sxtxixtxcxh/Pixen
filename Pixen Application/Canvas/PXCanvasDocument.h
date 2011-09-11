//
//  PXCanvasDocument.h
//  Pixen
//

#import <AppKit/NSDocument.h>
#import "PXDocument.h"

@class PXCanvas, PXCanvasPrintView, PXCanvasWindowController, PXCanvasController, NSString, NSTimer, PXBackground;

@interface PXCanvasDocument : PXDocument
{
  @private
	PXCanvas *canvas;
	PXCanvasPrintView *printableView;
}

+ (NSData *)dataRepresentationOfType:(NSString *)aType withCanvas:(PXCanvas *)canvas;
- (void)loadFromPasteboard:(NSPasteboard *)board;

- (PXCanvas *) canvas;
- (void)setCanvas:(PXCanvas *)aCanvas;

- (PXCanvasController*)canvasController;

@end
