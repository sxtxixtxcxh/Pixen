//
//  PXLayer.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXImage.h"
#import "PXPalette.h"

@class PXLayerController, PXCanvas;

@interface PXLayer : NSObject < NSCoding, NSCopying >
{
  @private
	PXImage *image;
	NSPoint origin;
	
	NSBezierPath *meldedBezier;
	NSColor *meldedColor;
	
	NSImage *cachedSourceOutImage;
	
	PXCanvas *canvas;
	
	BOOL _visible;
	NSString *_name;
	CGFloat _opacity;
}

@property (nonatomic, assign) BOOL visible;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CGFloat opacity;

@property (nonatomic, assign) PXCanvas *canvas;

+ (PXLayer *)layerWithName:(NSString *)name image:(NSImage *)image origin:(NSPoint)origin size:(NSSize)sz;
+ (PXLayer *)layerWithName:(NSString *)name image:(NSImage *)image size:(NSSize)sz;

- (id)initWithName:(NSString *)aName image:(PXImage *)anImage;
- (id)initWithName:(NSString *)aName size:(NSSize)size;
- (id)initWithName:(NSString *)aName size:(NSSize)size fillWithColor:(PXColor)color;

- (PXImage *)image;

//- (void)setUndoManager:(NSUndoManager *)man;

- (NSSize)size;
- (void)setSize:(NSSize)newSize;
- (void)setSize:(NSSize)newSize withOrigin:(NSPoint)origin backgroundColor:(PXColor)color;

- (NSPoint)origin;
- (void)setOrigin:(NSPoint)pt;

- (PXColor)colorAtIndex:(unsigned int)index;
- (PXColor)colorAtPoint:(NSPoint)aPoint;

- (void)setColor:(PXColor)color atPoint:(NSPoint)aPoint;
- (void)setColor:(PXColor)color atIndex:(unsigned int)index;

- (void)moveToPoint:(NSPoint)newOrigin;
- (void)translateXBy:(float)amountX yBy:(float)amountY;
- (void)finalizeMotion;
- (void)drawRect:(NSRect)rect;
- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(CGFloat)frac;
- (void)transformedDrawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(CGFloat)frac;
- (void)compositeUnder:(PXLayer *)aLayer flattenOpacity:(BOOL)flattenOpacity;
- (void)compositeUnder:(PXLayer *)aLayer inRect:(NSRect)aRect flattenOpacity:(BOOL)flattenOpacity;
- (void)compositeNoBlendUnder:(PXLayer *)aLayer inRect:(NSRect)aRect;

- (NSBitmapImageRep *)imageRep;

- (void)adaptToPalette:(PXPalette *)p withTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor;

- (void)meldBezier:(NSBezierPath *)path ofColor:(NSColor *)color;
- (void)unmeldBezier;

- (void)flipHorizontally;
- (void)flipVertically;
- (void)rotateByDegrees:(int)degrees;

- (void)rotateByDegrees:(int)degrees;

- (void)applyImageRep:(NSBitmapImageRep *)imageRep;

- (NSData *)colorData;
- (void)setColorData:(NSData *)data;

- (void)translateContentsByOffset:(NSPoint)offset;

@end
