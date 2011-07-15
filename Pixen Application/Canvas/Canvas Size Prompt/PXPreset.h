//
//  PXPreset.h
//  Pixen
//
//  Created by Matt Rajca on 7/15/11.
//  Copyright 2011 Matt Rajca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXPreset : NSObject < NSCoding > {
  @private
	NSString *name;
	NSSize size;
	NSColor *color;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSSize size;
@property (nonatomic, retain) NSColor *color;

@end
