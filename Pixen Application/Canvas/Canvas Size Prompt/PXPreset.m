//
//  PXPreset.m
//  Pixen
//
//  Created by Matt Rajca on 7/15/11.
//  Copyright 2011 Matt Rajca. All rights reserved.
//

#import "PXPreset.h"

@implementation PXPreset

@synthesize name, size, color;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		self.name = [aDecoder decodeObjectForKey:@"name"];
		self.size = [aDecoder decodeSizeForKey:@"size"];
		self.color = [aDecoder decodeObjectForKey:@"color"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:name forKey:@"name"];
	[aCoder encodeSize:size forKey:@"size"];
	[aCoder encodeObject:color forKey:@"color"];
}

- (void)dealloc
{
    [name release];
	[color release];
	[super dealloc];
}

@end
