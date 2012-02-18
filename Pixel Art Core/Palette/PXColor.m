//
//  PXColor.m
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "PXColor.h"

const static PXColor _blackColor = { 0, 0, 0, 255 };
const static PXColor _clearColor = { 0, 0, 0, 0 };

PXColor PXGetBlackColor()
{
	return _blackColor;
}

PXColor PXGetClearColor()
{
	return _clearColor;
}

PXColor PXColorMake(uint8_t r, uint8_t g, uint8_t b, uint8_t a)
{
	return (PXColor) { .r = r, .g = g, .b = b, .a = a };
}

PXColor PXColorFromNSColor(NSColor *color)
{
	return PXColorMake(round([color redComponent] * 255), round([color greenComponent] * 255),
					   round([color blueComponent] * 255), round([color alphaComponent] * 255));
}

NSColor *PXColorToNSColor(PXColor color)
{
	return [NSColor colorWithCalibratedRed:color.r / 255.0f green:color.g / 255.0f
									  blue:color.b / 255.0f alpha:color.a / 255.0f];
}

BOOL PXColorEqualsColor(PXColor color, PXColor otherColor)
{
	return color.r == otherColor.r && color.g == otherColor.g &&
		   color.b == otherColor.b && color.a == otherColor.a;
}

int PXColorDistanceToColor(PXColor color, PXColor otherColor)
{
	int r = color.r - otherColor.r;
	int g = color.g - otherColor.g;
	int b = color.b - otherColor.b;
	int a = color.a - otherColor.a;
	
	return abs(r) + abs(g) + abs(b) + abs(a);
}

PXColor PXColorBlendWithColor(PXColor bottomColor, PXColor topColor)
{
	CGFloat topA = topColor.a / 255.0f;
	CGFloat bottomA = bottomColor.a / 255.0f;
	
	CGFloat compositeA = topA + bottomA - (topA * bottomA);
	
	if (compositeA == 0) {
		return PXGetClearColor();
	}
	
	CGFloat topR = topColor.r / 255.0f;
	CGFloat topG = topColor.g / 255.0f;
	CGFloat topB = topColor.b / 255.0f;
	
	CGFloat bottomR = bottomColor.r / 255.0f;
	CGFloat bottomG = bottomColor.g / 255.0f;
	CGFloat bottomB = bottomColor.b / 255.0f;
	
	CGFloat compositeR = bottomR + ((topR - bottomR) * (topA / compositeA));
	CGFloat compositeB = bottomB + ((topB - bottomB) * (topA / compositeA));
	CGFloat compositeG = bottomG + ((topG - bottomG) * (topA / compositeA));
	
	return PXColorMake(round(compositeR * 255), round(compositeG * 255),
					   round(compositeB * 255), round(compositeA * 255));
}
