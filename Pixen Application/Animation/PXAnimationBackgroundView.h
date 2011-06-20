//
//  PXAnimationBackgroundView.h
//  Pixen
//
//  Created by Andy Matuschak on 10/16/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PXAnimationBackgroundView : NSView {
  @private
	NSGradient *horizontalGradient;
	NSScrollView *filmStrip;
}
@property (readwrite, retain) IBOutlet NSScrollView *filmStrip;
@end
