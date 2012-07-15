//
//  PXScaleAlgorithm.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXScaleAlgorithm.h"

#import "PXCanvas.h"

@implementation PXScaleAlgorithm

+ (id)algorithm
{
	return [[self alloc] init];
}

- (NSString *)name
{
	return [self nibName];
}

- (NSString *)nibName
{
	return nil;
}

- (NSString *)algorithmInfo
{
	return @"No information is available on this algorithm.";
}

- (BOOL)canScaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size
{
	return NO;
}

- (void)scaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size { }

@end
