//
//  PXCanvas.h
//  QLPlugin
//
//  Created by Matt Rajca on 7/16/11.
//  Copyright 2011 Matt Rajca. All rights reserved.
//

#import <Foundation/Foundation.h>

// barebones implementation to decode documents

@interface PXCanvas : NSObject < NSCoding >
{
  @private
	NSArray *layers;
}

- (void)draw;

- (NSSize)size;

@end
