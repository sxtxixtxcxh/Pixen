//
//  PXLayer.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "PXImage.h"
#import "PXPalette.h"
@class PXLayerController, PXCanvas;
@interface PXLayer : NSObject <NSCoding, NSCopying> {
  @private
	PXImage *image;
	NSPoint origin;
	
	NSBezierPath *meldedBezier;
	NSColor *meldedColor;
	
	NSImage *cachedSourceOutImage;
	
	PXCanvas *canvas;
}

@property (nonatomic, assign) BOOL visible;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CGFloat opacity;

+ (PXLayer *)layerWithName:(NSString *)name image:(NSImage *)image origin:(NSPoint)origin size:(NSSize)sz;
+ (PXLayer *)layerWithName:(NSString *)name image:(NSImage *)image size:(NSSize)sz;

- (id) initWithName:(NSString *)aName image:(PXImage *)anImage;
- (id)initWithName:(NSString *)aName size:(NSSize)size;
- initWithName:(NSString *)aName size:(NSSize)size fillWithColor:(NSColor *)c;

- (PXImage *)image;
//- (void)setUndoManager:(NSUndoManager *)man;
- (NSSize)size;
- (void)setSize:(NSSize)aSize;
- (void)setSize:(NSSize)newSize 
	 withOrigin:(NSPoint)origin
backgroundColor:(NSColor *)color;

- (NSPoint)origin;
- (void)setOrigin:(NSPoint)pt;

- (void)setCanvas:(PXCanvas *)canvas;
- (PXCanvas *)canvas;

- (NSColor *)colorAtIndex:(unsigned int)index;
- (NSColor *)colorAtPoint:(NSPoint)aPoint;
- (void)setColor:(NSColor *)aColor atPoint:(NSPoint)aPoint;
- (void)setColor:(NSColor *)c atIndex:(unsigned int)loc;

- (void)moveToPoint:(NSPoint)newOrigin;
- (void)translateXBy:(float)amountX yBy:(float)amountY;
- (void)finalizeMotion;
- (void)drawRect:(NSRect)rect;
- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(CGFloat)frac;
- (void)transformedDrawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(CGFloat)frac;
- (void)compositeUnder:(PXLayer *)aLayer flattenOpacity:(BOOL)flattenOpacity;
- (void)compositeUnder:(PXLayer *)aLayer inRect:(NSRect)aRect flattenOpacity:(BOOL)flattenOpacity;
- (void)compositeNoBlendUnder:(PXLayer *)aLayer inRect:(NSRect)aRect;
- (NSImage *)displayImage;
- (NSImage *)exportImage;
- (void)adaptToPalette:(PXPalette *)p withTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor;

- (void)meldBezier:(NSBezierPath *)path ofColor:(NSColor *)color;
- (void)unmeldBezier;

- (void)flipHorizontally;
- (void)flipVertically;
- (void)rotateByDegrees:(int)degrees;

- (void)rotateByDegrees:(int)degrees;

- (void)applyImage:(NSImage *)img;

- (PXLayer *)layerAfterApplyingMove;
@end
