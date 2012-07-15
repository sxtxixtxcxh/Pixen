//
//  NSArray_DeepMutableCopy.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "NSArray_DeepMutableCopy.h"

@implementation NSArray (DeepMutableCopy)

- (NSArray *)deepMutableCopy
{
	NSMutableArray *new = [[NSMutableArray alloc] initWithCapacity:[self count]];
	
	for (id current in self)
	{
		[new addObject:[current copy]];
	}
	
	return new;
}

@end
