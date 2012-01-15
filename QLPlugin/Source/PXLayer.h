//
//  PXLayer.h
//  QLPlugin
//
//  Created by Matt Rajca on 7/16/11.
//  Copyright 2011-2012 Matt Rajca. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PXImage.h"

@interface PXLayer : NSObject < NSCoding >
{
  @private
	BOOL visible;
	CGFloat opacity;
	PXImage *image;
}

- (void)draw;

- (NSSize)size;

@end
