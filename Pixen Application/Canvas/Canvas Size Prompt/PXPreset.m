//
//  PXPreset.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXPreset.h"

@implementation PXPreset

@synthesize name = _name, size = _size, color = _color;

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
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeSize:self.size forKey:@"size"];
	[aCoder encodeObject:self.color forKey:@"color"];
}

@end
