//
//  PXCanvas_Drawing.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXCanvas_Drawing.h"

#import "PXCanvas_Selection.h"
#import "PXLayer.h"

@implementation PXCanvas(Drawing)

- (void)drawRect:(NSRect)rect
{
	[self drawInRect:rect fromRect:rect];
}

- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src
{
	[self drawInRect:dst fromRect:src operation:NSCompositeSourceOver];
}

- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(CGFloat)frac
{
	for (PXLayer *layer in layers)
	{
		[layer drawInRect:dst fromRect:src operation:op fraction:frac];
	}
	
	for (PXLayer *layer in tempLayers)
	{
		[layer drawInRect:dst fromRect:src operation:op fraction:frac]; 
	}
}

- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op
{
	[self drawInRect:dst fromRect:src operation:op fraction:1];
}

- (void)meldBezier:(NSBezierPath *)path ofColor:(NSColor *)color
{
	[activeLayer meldBezier:path ofColor:color];
}

- (void)unmeldBezier
{
	[activeLayer unmeldBezier];
}

@end
