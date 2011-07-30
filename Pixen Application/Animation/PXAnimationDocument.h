//
//  PXAnimationDocument.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXDocument.h"
@class PXAnimationWindowController, PXAnimation;
@interface PXAnimationDocument : PXDocument {
  @private
	PXAnimation *animation;
}

@property (nonatomic, readonly) PXAnimation *animation;

@end
