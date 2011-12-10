//
//  PXCel.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@class PXCanvas, PXAnimation;

@interface PXCel : NSObject < NSCoding, NSCopying >
{
    PXCanvas *_canvas;
    NSTimeInterval _duration;
}

@property (nonatomic, retain) PXCanvas *canvas;

@property (nonatomic, assign) NSSize size;
@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, retain) NSDictionary *info;

- (id)initWithImage:(NSImage *)image animation:(PXAnimation *)animation;
- (id)initWithImage:(NSImage *)image animation:(PXAnimation *)animation atIndex:(NSUInteger)index;

- (id)initWithCanvas:(PXCanvas *)initCanvas duration:(NSTimeInterval)initDuration;

- (void)setUndoManager:(NSUndoManager *)manager;

- (void)setSize:(NSSize)size withOrigin:(NSPoint)origin backgroundColor:(NSColor *)bgcolor;

- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(CGFloat)frac;

- (NSImage *)displayImage;

@end
