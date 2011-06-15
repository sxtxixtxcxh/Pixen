//
//  PXAnimationBackgroundView.h
//  Pixen
//
//  Created by Andy Matuschak on 10/16/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CTGradient;
@interface PXAnimationBackgroundView : NSView {
	CTGradient *horizontalGradient;
	NSScrollView *filmStrip;
}

@end
