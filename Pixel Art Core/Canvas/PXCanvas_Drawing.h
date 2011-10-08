//
//  PXCanvas_Drawing.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXCanvas.h"

@interface PXCanvas (Drawing)

- (void)drawRect:(NSRect)rect;
- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(CGFloat)frac;
- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op;
- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src;
- (void)meldBezier:(NSBezierPath *)path ofColor:(NSColor *)color;
- (void)unmeldBezier;

@end
