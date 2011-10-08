//
//  NSArray_DeepMutableCopy.m
//  Pixen
//
//  Copyright 2004-2011 Pixen Project. All rights reserved.
//

#import "NSArray_DeepMutableCopy.h"

@implementation NSArray(DeepMutableCopy)

- (NSArray *)deepMutableCopy
{
	NSMutableArray *new = [[NSMutableArray alloc] initWithCapacity:[self count]];
	
	for (id current in self)
	{
		[new addObject:[[current copy] autorelease]];
	}
	
	return new;
}

@end
