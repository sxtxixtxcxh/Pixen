//
//  PXLayer.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXLayer.h"
#import "PXLayerController.h"
#import "PXImage.h"
#import "PXPalette.h"
#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Layers.h"
#import "NSObject+AssociatedObjects.h"

@implementation PXLayer

@synthesize visible = _visible, name = _name, opacity = _opacity;

+ (PXLayer *)layerWithName:(NSString *)name image:(NSImage *)image origin:(NSPoint)origin size:(NSSize)sz
{
	PXLayer *layer = [[PXLayer alloc] initWithName:name size:sz];
	// okay, now we have to make sure the image is the same size as the canvas
	// if it isn't, the weird premade image thing will cause serious problems.
	// soooo... haxx!
	NSImage *layerImage = [[[NSImage alloc] initWithSize:sz] autorelease];
	[layerImage lockFocus]; {
		[image drawAtPoint:origin fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeCopy fraction:1];			
	} [layerImage unlockFocus];
	[layer applyImage:layerImage];
	return [layer autorelease];
}

+ (PXLayer *)layerWithName:(NSString *)name image:(NSImage *)image size:(NSSize)sz
{
	return [self layerWithName:name image:image origin:NSZeroPoint size:sz];
}

- (id) initWithName:(NSString *) aName 
			  image:(PXImage *)anImage
{
	self = [super init];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(paletteChanged:)
			   name:PXPaletteChangedNotificationName
			 object:nil];
	[self setName:aName];
	if(anImage)
	{
		image = PXImage_retain(anImage);
	}
	origin = NSZeroPoint;
	
	self.opacity = 100;
	self.visible = YES;
	
	return self;
}

- (id)initWithName:(NSString *)aName size:(NSSize)size
{
	return [self initWithName:aName size:size fillWithColor:PXGetClearColor()];
}

- (id)initWithName:(NSString *)aName size:(NSSize)size fillWithColor:(PXColor)color
{
	self = [self initWithName:aName image:nil];
	if (self) {
		image = PXImage_initWithSize(PXImage_alloc(), size);
		
		if (image)
			PXImage_clear(image, color);
	}
	return self;
}

- (void)dealloc
{
	[_name release];
	[meldedBezier release];
	[meldedColor release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	PXImage_release(image);
	[super dealloc];
}

- (PXImage *)image
{
	return image;
}

- (void)setVisible:(BOOL)state
{
	if (_visible != state) {
		_visible = state;
		[[self canvas] changed];
	}
}

- (PXColor)colorAtIndex:(unsigned int)index
{
	if (!canvas) {
		NSAssert(0, @"[PXLayer colorAtIndex:] - no canvas (this should never execute)");
	}
	
	return PXImage_colorAtIndex(image, index);
}

- (PXColor)colorAtPoint:(NSPoint)pt
{
	NSPoint point = pt;
	
	if (canvas)
	{
		point = [canvas correct:pt];
		
		if (point.x >= [self size].width || point.x < 0 ||
			point.y >= [self size].height || point.y < 0) {
			
			return PXGetClearColor();
		}
	}
	
	return PXImage_colorAtXY(image, point.x, point.y);
}

- (void)setColor:(PXColor)color atIndex:(unsigned int)index
{
	PXImage_setColorAtIndex(image, color, index);
}

- (void)setOpacity:(CGFloat)state
{
	if (_opacity != state) {
		_opacity = state;
		[[self canvas] changed];
	}
}

- (void)setColor:(PXColor)color atPoint:(NSPoint)pt
{
	NSPoint point = pt;
	
	if (canvas)
	{
		point = [canvas correct:pt];
		
		if (point.x >= [self size].width || point.x < 0 ||
			point.y >= [self size].height || point.y < 0) {
			
			return;
		}
	}
	
	PXImage_setColorAtXY(image, color, point.x, point.y);
}

- (void)rotateByDegrees:(int)degrees
{
	PXImage_rotateByDegrees(image, degrees);
}

- (void)moveToPoint:(NSPoint)newOrigin
{
	origin = newOrigin;
}

- (NSSize)size
{
	if (image == NULL) {
		return NSZeroSize;
	}
	return NSMakeSize(image->width, image->height);
}

- (void)setCanvas:(PXCanvas *)c
{
	canvas = c;
}

- (PXCanvas *)canvas
{
	return canvas;
}

- (void)meldBezier:(NSBezierPath *)path ofColor:(NSColor *)color
{
	[meldedColor release];
	meldedColor = [color retain];
	meldedBezier = [path retain];
}

- (void)unmeldBezier
{
	[meldedBezier release];
	meldedBezier = nil;
}

- (void)setSize:(NSSize)newSize withOrigin:(NSPoint)point backgroundColor:(PXColor)color
{
	PXImage_setSize(image, newSize, point, color);
}

- (void)setSize:(NSSize)newSize
{
	PXImage_setSize(image, newSize, NSZeroPoint, [[self canvas] eraseColor]);
}

- (NSPoint)origin
{
	return origin;
}

- (void)setOrigin:(NSPoint)pt
{
	origin = pt;
}

- (void)finalizeMotion
{
	NSPoint point = [canvas correct:origin];
	PXImage_translate(image, point.x, point.y, [canvas wraps]);
	origin = NSZeroPoint;
	[canvas changedInRect:NSMakeRect(0, 0, [self size].width, [self size].height)];
}

- (void)translateXBy:(float)amountX yBy:(float)amountY
{
	[self moveToPoint:NSMakePoint(origin.x + amountX, origin.y + amountY)];
}

- (void)transformedDrawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(CGFloat)frac
{
	if(NSWidth(src) == 0 || NSHeight(src) == 0) {
		return;
	}
	if(meldedBezier != nil) {
		float widthScale = NSWidth(dst) / NSWidth(src);
		float heightScale = NSHeight(dst) / NSHeight(src);
		NSAffineTransform *transform = [NSAffineTransform transform];
		[transform scaleXBy:widthScale yBy:heightScale];

		if([meldedColor alphaComponent] == 1) {
			PXImage_drawInRectFromRectWithOperationFraction(image, dst, src, op, frac * ([self opacity] / 100.0));
			[meldedColor set];
			[[transform transformBezierPath:meldedBezier] fill];
		} else {
			NSSize fullSize = NSMakeSize((widthScale * NSWidth(src)),
										 (heightScale * NSHeight(src)));
			if(!cachedSourceOutImage || 
			   (fullSize.width > [cachedSourceOutImage size].width) || 
			   (fullSize.height > [cachedSourceOutImage size].height))
			{
				[cachedSourceOutImage release];
				cachedSourceOutImage = [[NSImage alloc] initWithSize:fullSize];
			}
			[cachedSourceOutImage lockFocus];
			NSRectFillUsingOperation(NSMakeRect(0, 0, [cachedSourceOutImage size].width, [cachedSourceOutImage size].height), NSCompositeClear);
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
			[[NSGraphicsContext currentContext] setShouldAntialias:NO];
			[[NSColor blackColor] set];
			NSAffineTransform *translate = [NSAffineTransform transform];
			[translate translateXBy:-src.origin.x*widthScale yBy:-src.origin.y*heightScale];
			[translate concat];
			[[transform transformBezierPath:meldedBezier] fill];
			PXImage_drawInRectFromRectWithOperationFraction(image, 
															NSMakeRect(0, 0, NSWidth(src)*widthScale, NSHeight(src)*heightScale), 
															src, 
															NSCompositeSourceOut, 
															1);
			[translate invert];
			[translate concat];
			[cachedSourceOutImage unlockFocus];
			[cachedSourceOutImage drawInRect:dst 
									fromRect:NSMakeRect(0, 0, NSWidth(src)*widthScale, NSHeight(src)*heightScale) 
								   operation:op
									fraction:frac * ([self opacity] / 100.0)];
			[meldedColor set];
			[[transform transformBezierPath:meldedBezier] fill];
		}
		
	} else {
		PXImage_drawInRectFromRectWithOperationFraction(image, dst, src, op, frac * ([self opacity] / 100.0));
	}
} 

- (void)drawRect:(NSRect)rect
{
	[self drawInRect:rect fromRect:rect operation:NSCompositeSourceOver fraction:1];
}

- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src
{
	[self drawInRect:dst fromRect:src operation:NSCompositeSourceOver fraction:1];
}

- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(CGFloat)frac
{
	if (!self.visible || self.opacity == 0)
		return;
	
//FIXME: this shouldn't be here
	float widthScale = NSWidth(dst) / NSWidth(src);
	float heightScale = NSHeight(dst) / NSHeight(src);
	float xOff = widthScale*origin.x+(dst.origin.x-(src.origin.x*widthScale));
	float yOff = heightScale*origin.y+(dst.origin.y-(src.origin.y*heightScale));
	CGContextTranslateCTM([[NSGraphicsContext currentContext] graphicsPort], xOff, yOff);
	[self transformedDrawInRect:dst fromRect:src operation:op fraction:frac];
	CGContextTranslateCTM([[NSGraphicsContext currentContext] graphicsPort], -xOff, -yOff);
}

//FIXME: maybe should not be here ? 
//It's called, it makes the calling simpler, it's worth keeping.
- (void)compositeUnder:(PXLayer *)aLayer flattenOpacity:(BOOL)flattenOpacity
{
	[self compositeUnder:aLayer inRect:NSMakeRect(0, 0, [self size].width, [self size].height) flattenOpacity:flattenOpacity];
}

- (void)compositeUnder:(PXLayer *)aLayer inRect:(NSRect)aRect flattenOpacity:(BOOL)flattenOpacity
{
	int i, j;
	if(flattenOpacity)
	{
		for (i=NSMinX(aRect); i < NSMaxX(aRect); i++)
		{
			for (j=NSMinY(aRect); j < NSMaxY(aRect); j++)
			{
				NSPoint point = NSMakePoint(i, j);
				
				PXColor color1 = PXImage_colorAtXY(image, point.x, point.y);
				PXColor color2 = PXImage_colorAtXY([aLayer image], point.x, point.y);
				
				if (flattenOpacity) {
					color1.a *= [self opacity] / 100.0f;
					color2.a *= [self opacity] / 100.0f;
				}
				
				PXImage_setColorAtXY(image, color1, point.x, point.y);
				PXImage_setColorAtXY([aLayer image], color2, point.x, point.y);
			}
		}
	}
	PXImage_compositeUnderInRect(image, [aLayer image], aRect, YES);
	if (flattenOpacity) 
	{ 
		[self setOpacity:MAX(self.opacity, [aLayer opacity])]; 
	}
	
	[canvas changed];
}

- (void)compositeNoBlendUnder:(PXLayer *)aLayer inRect:(NSRect)aRect
{
	PXImage_compositeUnderInRect(image, [aLayer image], aRect, NO);	
}

- (NSImage *)exportImage
{
	return PXImage_bitmapImage(image);
}

- (NSImage *)displayImage
{
	return PXImage_NSImage(image);
}

- (void)flipHorizontally
{
	PXImage_flipHorizontally(image);
}

- (void)flipVertically
{
	PXImage_flipVertically(image);
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	
	image = PXImage_initWithCoder(PXImage_alloc(), coder, (PXPalette *)[coder associatedValueForKey:@"palette"]);
	
	self.name = [coder decodeObjectForKey:@"name"];
	self.visible = [coder containsValueForKey:@"visible"] ? [coder decodeBoolForKey:@"visible"] : YES;
	self.opacity = [coder decodeObjectForKey:@"opacity"] ? [[coder decodeObjectForKey:@"opacity"] doubleValue] : 100;
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	PXImage_encodeWithCoder(image, coder);
	[coder encodeObject:self.name forKey:@"name"];
	[coder encodeBool:self.visible forKey:@"visible"];
	[coder encodeObject:[NSNumber numberWithDouble:self.opacity] forKey:@"opacity"];
}

- (void)_setImage:(PXImage *)newImage
{
	image = newImage;
}

-(id) copyWithZone:(NSZone *)zone
{
	PXLayer * copy = [[[self class] alloc] initWithName:self.name image:PXImage_copy(image)];
	PXImage_release([copy image]);
	[copy setCanvas:[self canvas]];
	[copy setOpacity:self.opacity];
	[copy setVisible:self.visible];
	return copy;
}

- (void)translateContentsByOffset:(NSPoint)offset
{
	PXImage_setSize(image, [self size], offset, [canvas eraseColor]);
}

- (void)applyImage:(NSImage *)anImage
{
    // this is probably pretty fragile. there should be a better way of doing this, no?
	NSImageRep *firstRep = [[anImage representations] objectAtIndex:0];
	NSBitmapImageRep *imageRep = nil;
	
	if (![firstRep isKindOfClass:[NSBitmapImageRep class]])
	{
		[anImage lockFocus];
		imageRep = [NSBitmapImageRep imageRepWithData:[anImage TIFFRepresentation]];
		[anImage unlockFocus];
	}
	else
	{
		imageRep = (NSBitmapImageRep *) firstRep;
	}
	
	imageRep = [imageRep bitmapImageRepByConvertingToColorSpace:[NSColorSpace genericRGBColorSpace]
												renderingIntent:NSColorRenderingIntentDefault];
	
	NSInteger width = [imageRep pixelsWide];
	NSInteger height = [imageRep pixelsHigh];
	
	for (NSInteger i = 0; i < width; i++)
	{
		for (NSInteger j = 0; j < height; j++)
		{
			[self setColor:PXColorFromNSColor([imageRep colorAtX:i y:j])
				   atPoint:NSMakePoint(i, height - j - 1)];
		}
	}
}

- (void)adaptToPalette:(PXPalette *)p withTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor
{
	id outputImage = [[[self displayImage] copy] autorelease];
	id rep = [NSBitmapImageRep imageRepWithData:[outputImage TIFFRepresentation]];
	unsigned char *bitmapData = [rep bitmapData];
	int i;
	NSColor *calibratedClear = [[NSColor clearColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	if (![rep hasAlpha])
		transparency = NO;
	for (i = 0; i < [self size].width * [self size].height; i++)
	{
		NSInteger base = i * [rep samplesPerPixel];
		NSColor *color;
		if (transparency && bitmapData[base + 3] == 0)
		{
			color = calibratedClear;
		}
		else if (transparency && matteColor && bitmapData[base + 3] < 255)
		{
			NSColor *sourceColor = [NSColor colorWithCalibratedRed:bitmapData[base + 0] / 255.0f green:bitmapData[base + 1] / 255.0f blue:bitmapData[base + 2] / 255.0f alpha:1];
			color = [matteColor blendedColorWithFraction:(bitmapData[base + 3] / 255.0f) ofColor:sourceColor];
		}
		else
		{
			color = [NSColor colorWithCalibratedRed:bitmapData[base + 0] / 255.0f green:bitmapData[base + 1] / 255.0f blue:bitmapData[base + 2] / 255.0f alpha:1];
		}
		
		[self setColor:PXColorFromNSColor([p colorClosestToColor:color]) atIndex:i];
	}
}

@end
