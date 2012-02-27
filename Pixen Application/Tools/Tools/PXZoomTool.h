//
//  PXZoomTool.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXTool.h"

typedef enum {
    PXZoomIn = 0,
    PXZoomOut
} PXZoomType;

@interface PXZoomTool : PXTool
{
  @private
	PXZoomType _zoomType;
}

@end
