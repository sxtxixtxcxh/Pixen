//
//  PXCanvasPrintView.h
//  Pixen
//

#import <AppKit/NSView.h>
@class PXCanvas;

@interface PXCanvasPrintView : NSView 
{
  @private
	PXCanvas *canvas;
}

+ (id) viewForCanvas:(PXCanvas *)aCanvas;
- (id) initWithCanvas:(PXCanvas *)aCanvas;

@end
