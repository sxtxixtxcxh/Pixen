//
//  OSLinearGradient.m
//  Pixen
//
//  Created by Ian Henderson on 10.10.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "OSLinearGradient.h"


@implementation OSLinearGradient

- (void)drawFromPoint:(NSPoint)start toPoint:(NSPoint)end inRect:(NSRect)rect
{
	CGShadingRef shadingRef = CGShadingCreateAxial(colorSpace, CGPointMake(start.x, start.y), CGPointMake(end.x, end.y), shadingFunction, NO, NO);
	[self _drawShadingRef:shadingRef inRect:rect];
	CGShadingRelease(shadingRef);
}

@end
