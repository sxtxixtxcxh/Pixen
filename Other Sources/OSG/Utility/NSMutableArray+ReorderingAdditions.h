//
//  NSMutableArray+ReorderingAdditions.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import <Foundation/NSArray.h>

@interface NSMutableArray (ReorderingAdditions)

- (void)moveObjectAtIndex:(NSUInteger)initialIndex toIndex:(NSUInteger)targetIndex;

@end
