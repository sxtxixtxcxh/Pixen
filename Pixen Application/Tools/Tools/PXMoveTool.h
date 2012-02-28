//
//  PXMoveTool.h
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXLinearTool.h"

@class PXCanvas, PXLayer;

typedef enum {
	PXMoveTypeNone = 0,
	PXMoveTypeMoving,
	PXMoveTypeCopying
} PXMoveType;

@interface PXMoveTool : PXLinearTool
{
  @private
	PXLayer *copyLayer, *moveLayer;
	PXMoveType type;
	BOOL entireImage;
	NSPoint selectionOrigin;
	NSRect selectedRect, lastSelectedRect;
}

- (void)updateCopyLayerForCanvas:(PXCanvas *)canvas;

@end
