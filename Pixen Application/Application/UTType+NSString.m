//
//  UTType+NSString.m
//  Pixen
//
//  Copyright 2011 Pixen. All rights reserved.
//

#import "UTType+NSString.h"

BOOL UTTypeEqualNSString (NSString *one, NSString *two)
{
	CFStringRef oneCF = (__bridge CFStringRef) one;
	CFStringRef twoCF = (__bridge CFStringRef) two;
	
	return UTTypeEqual(oneCF, twoCF);
}
