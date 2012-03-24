//
//  PXCanvasAnchorView.h
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

typedef enum {
	PXCanvasAnchorTopLeft = 0,
	PXCanvasAnchorTopCenter,
	PXCanvasAnchorTopRight,
	PXCanvasAnchorCenterLeft,
	PXCanvasAnchorCenter,
	PXCanvasAnchorCenterRight,
	PXCanvasAnchorBottomLeft,
	PXCanvasAnchorBottomCenter,
	PXCanvasAnchorBottomRight
} PXCanvasAnchor;

@interface PXCanvasAnchorView : NSView
{
  @private
	PXCanvasAnchor _anchor;
}

@property (nonatomic, assign) PXCanvasAnchor anchor;

@end
