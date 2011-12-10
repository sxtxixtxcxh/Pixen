//
//  PXAnimationDocument.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXDocument.h"

@class PXAnimation;

@interface PXAnimationDocument : PXDocument
{
    PXAnimation *_animation;
}

@property (nonatomic, readonly) PXAnimation *animation;

@end
