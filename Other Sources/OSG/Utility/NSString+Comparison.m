//
//  NSString+Comparison.m
//  Pixen
//
//  Copyright 2009-2012 Pixen Project. All rights reserved.
//

#import "NSString+Comparison.h"

@implementation NSString (CompareNumeric)

- (NSComparisonResult)compareNumeric:(NSString *)other
{
	return [self compare:other options:NSNumericSearch | NSCaseInsensitiveSearch];
}

@end