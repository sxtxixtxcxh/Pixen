//
//  NSMutableArray+ReorderingAdditions.h
//  Pixen
//
//  Created by Ian Henderson on 10.08.05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableArray(ReorderingAdditions)

- (void)moveObjectAtIndex:(NSUInteger)initialIndex toIndex:(NSUInteger)targetIndex;

@end
