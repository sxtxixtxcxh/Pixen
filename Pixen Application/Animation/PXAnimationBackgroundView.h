//
//  PXAnimationBackgroundView.h
//  Pixen
//
//  Created by Andy Matuschak on 10/16/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OSGradient;
@interface PXAnimationBackgroundView : NSView {
	OSGradient *horizontalGradient;
	id filmStrip;
}

@end
