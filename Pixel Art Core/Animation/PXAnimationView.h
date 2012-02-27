//
//  PXAnimationView.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasView.h"

@interface PXAnimationView : PXCanvasView
{
  @private
	NSImage *_previousCelImage;
}

@property (nonatomic, retain) NSImage *previousCelImage;

@end
