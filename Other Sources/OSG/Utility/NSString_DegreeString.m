//
//  NSString_DegreeString.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "NSString_DegreeString.h"

@implementation NSString (DegreeString)

+ (NSString *)degreeString
{
	UniChar degree[] = { 0x00B0 };
	return [self stringWithCharacters:degree length:1];
}

@end
