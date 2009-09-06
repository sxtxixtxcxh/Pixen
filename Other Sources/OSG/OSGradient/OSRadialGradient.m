//
//  OSRadialGradient.m
//  Pixen
//
//  Created by Ian Henderson on 10.10.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "OSRadialGradient.h"


@implementation OSRadialGradient

- (void)drawFromCenter:(NSPoint)start toCenter:(NSPoint)end fromRadius:(float)startRadius toRadius:(float)endRadius inRect:(NSRect)rect
{
	CGShadingRef shadingRef = CGShadingCreateRadial(colorSpace, CGPointMake(start.x, start.y), startRadius, CGPointMake(end.x, end.y), endRadius, shadingFunction, NO, NO);
	[self _drawShadingRef:shadingRef inRect:rect];
	CGShadingRelease(shadingRef);
}

- (void)drawFromPoint:(NSPoint)start toPoint:(NSPoint)end inRect:(NSRect)rect
{
	[self drawFromCenter:start toCenter:start fromRadius:0 toRadius:sqrt(end.x * end.x + end.y * end.y) inRect:rect];
}

@end
