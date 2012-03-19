//
//  NSColor+PXPaletteAdditions.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "NSColor+PXPaletteAdditions.h"

@implementation NSColor (PXPaletteAdditions)

- (float)distanceTo:(NSColor *)other
{
	NSColor *here = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	NSColor *there = [other colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	
	CGFloat hereC[4], thereC[4];
	[here getComponents:hereC];
	[there getComponents:thereC];
	
	float r = hereC[0]-thereC[0];
	float g = hereC[1]-thereC[1];
	float b = hereC[2]-thereC[2];
	float a = hereC[3]-thereC[3];
	
	return fabsf(r) + fabsf(g) + fabsf(b) + fabsf(a);
}

@end
