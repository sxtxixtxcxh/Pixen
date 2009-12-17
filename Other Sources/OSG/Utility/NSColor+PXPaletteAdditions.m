//
//  NSColor+PXPaletteAdditions.m
//  Pixen
//
//  Created by Andy Matuschak on 7/2/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "NSColor+PXPaletteAdditions.h"


@implementation NSColor(PXPaletteAdditions)

- (unsigned int)paletteHash
{
	unsigned int r = [self redComponent]*255;
	unsigned int g = [self greenComponent]*255;
	unsigned int b = [self blueComponent]*255;
	unsigned int a = [self alphaComponent]*255;
	return (r * g) ^ (b * a);
}

- (float)distanceTo:(NSColor *)other
{
	NSColor *here = [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	NSColor *there = [other colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	
	float r = [here redComponent] - [there redComponent];
	float g = [here greenComponent] - [there greenComponent];
	float b = [here blueComponent] - [there blueComponent];
	float a = [here alphaComponent] - [there alphaComponent];
	return fabsf(r) + fabsf(g) + fabsf(b) + fabsf(a);
}

@end
