//
//  PXCanvas.m
//  QLPlugin
//
//  Created by Matt Rajca on 7/16/11.
//  Copyright 2011 Matt Rajca. All rights reserved.
//

#import "PXCanvas.h"

#import "PXLayer.h"

@implementation PXCanvas

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
		int version = [coder decodeIntForKey:@"version"];
		
		if (version < 4)
			layers = [[coder decodeObjectForKey:@"layers"] retain];
    }
    return self;
}

- (void)dealloc
{
	[layers release];
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder { }

- (void)draw
{
	for (PXLayer *layer in layers) {
		[layer draw];
	}
}

- (NSSize)size
{
	if ([layers count] > 0) {
		PXLayer *firstLayer = [layers objectAtIndex:0];
		return [firstLayer size];
	}
	
	return NSZeroSize;
}

@end
