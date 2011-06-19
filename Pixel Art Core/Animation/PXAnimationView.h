//
//  PXAnimationView.h
//  Pixen
//
//  Created by Andy Matuschak on 8/11/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvasView.h"

@interface PXAnimationView : PXCanvasView {
  @private
	NSImage *previousCel;
}

- (void)setPreviousCelImage:(NSImage *)previousCel;

@end
