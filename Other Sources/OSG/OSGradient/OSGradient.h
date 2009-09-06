//
//  OSGradient.h
//  Pixen
//
//  Created by Ian Henderson on 10.10.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OSGradient : NSObject {
	NSColor *startColor, *endColor;
#ifdef __COCOA__
	CGColorSpaceRef colorSpace;
	CGFunctionRef shadingFunction;
#endif
}

- initWithStartColor:(NSColor *)start endColor:(NSColor *)end;
+ (OSGradient *)gradientWithStartColor:(NSColor *)start endColor:(NSColor *)end;
#ifdef __COCOA__
- (void)_drawShadingRef:(CGShadingRef)shading inRect:(NSRect)rect;
#endif
- (NSColor *)startColor;
- (void)setStartColor:(NSColor *)color;
- (NSColor *)endColor;
- (void)setEndColor:(NSColor *)color;

- (void)drawFromPoint:(NSPoint)start toPoint:(NSPoint)end inRect:(NSRect)rect;

@end
