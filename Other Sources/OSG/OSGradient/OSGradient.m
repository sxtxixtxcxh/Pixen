//
//  OSGradient.m
//  Pixen
//
//  Created by Ian Henderson on 10.10.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "OSGradient.h"


typedef struct
{
	float r1, g1, b1, a1;
	float r2, g2, b2, a2;
} _OSGradientTwoColors;

void OSLinearColorBlendFunction(void *info, const float *in, float *out)
{
	_OSGradientTwoColors *twoColors = info;
	out[0] = (1.0 - *in) * twoColors->r1 + *in * twoColors->r2;
	out[1] = (1.0 - *in) * twoColors->g1 + *in * twoColors->g2;
	out[2] = (1.0 - *in) * twoColors->b1 + *in * twoColors->b2;
	out[3] = (1.0 - *in) * twoColors->a1 + *in * twoColors->a2;
}

void OSLinearColorReleaseInfoFunction(void *twoColors)
{
	free(twoColors);
}

static const CGFunctionCallbacks linearFunctionCallbacks = { 0, &OSLinearColorBlendFunction, &OSLinearColorReleaseInfoFunction };


@implementation OSGradient

- init
{
	if ([super init] == nil) {
		return nil;
	}
	colorSpace = CGColorSpaceCreateDeviceRGB();
	return self;
}

- (void)_updateColors
{
	NSColor *color1 = [self startColor];
	NSColor *color2 = [self endColor];
	if ([color1 colorSpaceName] != NSCalibratedRGBColorSpace)
		color1 = [color1 colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	if ([color2 colorSpaceName] != NSCalibratedRGBColorSpace)
		color2 = [color2 colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	
	_OSGradientTwoColors *twoColors = malloc(sizeof(_OSGradientTwoColors));
	[color1 getRed:&twoColors->r1 green:&twoColors->g1 blue:&twoColors->b1 alpha:&twoColors->a1];
	[color2 getRed:&twoColors->r2 green:&twoColors->g2 blue:&twoColors->b2 alpha:&twoColors->a2];
	
	static const float domainAndRange[8] = { 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0 };
	shadingFunction = CGFunctionCreate(twoColors, 1, domainAndRange, 4, domainAndRange, &linearFunctionCallbacks);	
}

- initWithStartColor:(NSColor *)start endColor:(NSColor *)end
{
	if ([self init] == nil) {
		return nil;
	}
	startColor = [start retain];
	endColor = [end retain];
	[self _updateColors];
	return self;
}

+ (OSGradient *)gradientWithStartColor:(NSColor *)start endColor:(NSColor *)end
{
	return [[[self alloc] initWithStartColor:start endColor:end] autorelease];
}

- (void)dealloc
{
	CGColorSpaceRelease(colorSpace);
	[super dealloc];
}

- (void)_drawShadingRef:(CGShadingRef)shading inRect:(NSRect)rect
{
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(context); {
		CGContextClipToRect(context, (CGRect){ { NSMinX(rect), NSMinY(rect) }, { NSWidth(rect), NSHeight(rect) } });
		CGContextDrawShading(context, shading);
	} CGContextRestoreGState(context);
}

- (NSColor *)startColor
{
	return startColor;
}

- (void)setStartColor:(NSColor *)color
{
	[color retain];
	[startColor release];
	startColor = color;
	[self _updateColors];
}

- (NSColor *)endColor
{
	return endColor;
}

- (void)setEndColor:(NSColor *)color
{
	[color retain];
	[endColor release];
	endColor = color;
	[self _updateColors];
}

- (void)drawFromPoint:(NSPoint)start toPoint:(NSPoint)end inRect:(NSRect)rect
{
	[[NSException exceptionWithName:@"PXYouIdiotException" reason:@"You're not even supposed to see this message!  It's just here for comic relief!" userInfo:nil] raise];
}

@end
