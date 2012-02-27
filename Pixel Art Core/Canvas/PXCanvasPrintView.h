//
//  PXCanvasPrintView.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@class PXCanvas;

@interface PXCanvasPrintView : NSView
{
  @private
	PXCanvas *_canvas;
}

+ (id)viewForCanvas:(PXCanvas *)aCanvas;

- (id)initWithCanvas:(PXCanvas *)aCanvas;

@end
