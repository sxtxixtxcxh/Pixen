//
//  PXAnimationBackgroundView.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXAnimationBackgroundView : NSView
{
  @private
	NSGradient *_horizontalGradient;
}

@property (nonatomic, weak) IBOutlet NSScrollView *filmStrip;

@end
