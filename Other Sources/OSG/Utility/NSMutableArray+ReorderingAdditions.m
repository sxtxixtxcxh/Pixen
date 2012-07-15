//
//  NSMutableArray+ReorderingAdditions.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "NSMutableArray+ReorderingAdditions.h"

@implementation NSMutableArray (ReorderingAdditions)

- (void)moveObjectAtIndex:(NSUInteger)initialIndex toIndex:(NSUInteger)targetIndex
{
	if (targetIndex != initialIndex) {
		id obj = [self objectAtIndex:initialIndex];
		[self removeObjectAtIndex:initialIndex];
		
		if (targetIndex >= [self count]) {
			[self addObject:obj];
		}
		else {
			[self insertObject:obj atIndex:targetIndex];
		}
	}
}

@end
