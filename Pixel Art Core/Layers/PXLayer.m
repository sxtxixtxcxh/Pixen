//
//  PXLayer.m
//  Pixen-XCode
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Joe Osborn on Sun Jan 04 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXLayer.h"
#import "PXLayerController.h"
#import "PXImage.h"
#import "PXPalette.h"
#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Layers.h"

@interface NSCalibratedRGBColor:NSColor
{
	float redComponent, greenComponent, blueComponent, alphaComponent;
	struct CGColor *cachedColor;
}
- (id)initWithRed:(float)r green:(float)g blue:(float)b alpha:(float)a;
@end

@interface NSDeviceRGBColor : NSCalibratedRGBColor
@end

@implementation PXLayer

+ (PXLayer *)layerWithName:(NSString *)name image:(NSImage *)image origin:(NSPoint)origin size:(NSSize)sz palette:(PXPalette *)pal
{
	id layer = [[PXLayer alloc] initWithName:name size:sz];
	[layer setPalette:pal];
	// okay, now we have to make sure the image is the same size as the canvas
	// if it isn't, the weird premade image thing will cause serious problems.
	// soooo... haxx!
	NSImage *layerImage = [[[NSImage alloc] initWithSize:sz] autorelease];
	[layerImage lockFocus]; {
		[image drawAtPoint:origin fromRect:NSMakeRect(0, 0, [image size].width, [image size].height) operation:NSCompositeCopy fraction:1];			
	} [layerImage unlockFocus];
	[layer applyImage:layerImage];
	return layer;
}

+ (PXLayer *)layerWithName:(NSString *)name image:(NSImage *)image size:(NSSize)sz palette:(PXPalette *)pal
{
	return [self layerWithName:name image:image origin:NSZeroPoint size:sz palette:pal];
}

- (id) initWithName:(NSString *) aName 
			  image:(PXImage *)anImage
{
	[super init];
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
	meldedColor = nil;
	meldedBezier = nil;
	canvas = nil;
	opacity = 100;
	visible = YES;
	return self;
}

-(id) initWithName:(NSString *) aName size:(NSSize)size
{
	return [self initWithName:aName size:size fillWithColorIndex:0];
}

- initWithName:(NSString *)aName size:(NSSize)size fillWithColorIndex:(unsigned int)index
{
	[self initWithName:aName image:nil];
	image = PXImage_initWithSize(PXImage_alloc(), size);
	if (index != 0) // we do this instead of use the normal methods in order to get around error checking: this layer and image don't have a palette yet.
	{
		int i;
		for (i = 0; i < size.width * size.height; i++)
		{
			image->colorIndices[i] = index;
		}
	}
	return self;
}

- (void)dealloc
{
	[name release];
	[meldedBezier release];
	[meldedColor release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	PXImage_release(image);
	[super dealloc];
}

-(NSString *) name
{
	return name;
}

- (void)setName:(NSString *)aName
{
	[name release];
	name = [aName copy];
}

- (void)setColorIndex:(unsigned int)colorIndex atPoint:(NSPoint)pt
{
	NSPoint point = pt;
	if(canvas)
	{
		point = [canvas correct:pt];
		if(point.x >= [self size].width ||
		   point.x < 0 ||
		   point.y >= [self size].height ||
		   point.y < 0)
		{
			return;
		}
	}
	PXImage_setColorIndexAtXY(image, point.x, point.y, colorIndex);
}					

- (PXImage *)image
{
	return image;
}

- (double)opacity
{
	if ([canvas palette]->locked)
		return 100;
	return opacity;
}

- (void)setOpacity:(double)newOpacity
{
	opacity = newOpacity;
}

- (BOOL)visible
{
	return visible;
}

- (void)setVisible:(BOOL)isVisible
{
	visible = isVisible;
}

- (NSColor *)colorAtIndex:(unsigned int)index
{
	if (!canvas) { return nil; }
	return PXPalette_colorAtIndex([canvas palette], [self colorIndexAtIndex:index]);
}

- (NSColor *)colorAtPoint:(NSPoint)pt
{
	NSPoint point = pt;
	if(canvas)
	{
		point = [canvas correct:pt];
		if(point.x >= [self size].width ||
		   point.x < 0 ||
		   point.y >= [self size].height ||
		   point.y < 0)
		{
			return [NSColor clearColor];
		}
	}
	return PXImage_colorAtXY(image, point.x, point.y);
}

- (unsigned int)colorIndexAtIndex:(unsigned)index
{
	return PXImage_colorIndexAtIndex(image, index);
}

- (void)setColorIndex:(unsigned int)index atIndex:(unsigned int)loc
{
	PXImage_setColorIndexAtIndex(image, index, loc);
}

- (unsigned int)colorIndexAtPoint:(NSPoint)pt
{
	NSPoint point = pt;
	if(canvas)
	{
		point = [canvas correct:pt];
		if(point.x >= [self size].width ||
		   point.x < 0 ||
		   point.y >= [self size].height ||
		   point.y < 0)
		{
			return 0;
		}
	}
	return PXImage_colorIndexAtXY(image, point.x, point.y);
}

- (void)setColor:(NSColor *)color atPoint:(NSPoint)pt
{
	NSPoint point = pt;
	if(canvas)
	{
		point = [canvas correct:pt];
		if(point.x >= [self size].width ||
		   point.x < 0 ||
		   point.y >= [self size].height ||
		   point.y < 0)
		{
			return;
		}
	}
	PXImage_setColorAtXY(image, point.x, point.y, color);
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
	PXImage_setPalette(image, [canvas palette]);
}

- (PXCanvas *)canvas
{
	return canvas;
}

- (void)meldBezier:(NSBezierPath *)path ofColor:(NSColor *)color
{
	[meldedColor release];
	meldedColor = [PXPalette_restrictColor(image->palette, color) retain];
	meldedBezier = [path retain];
}

- (void)unmeldBezier
{
	[meldedBezier release];
	meldedBezier = nil;
}

- (void)setSize:(NSSize)newSize withOrigin:(NSPoint)point backgroundColor:(NSColor *)color
{
	PXImage_setSize(image, newSize, point, PXPalette_indexOfColorAddingIfNotPresent(image->palette, color));
}

- (void)setSize:(NSSize)newSize
{
	PXImage_setSize(image, newSize, NSZeroPoint, 0);
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
	[self beginOptimizedSetting];
	NSPoint point = [canvas correct:origin];
	PXImage_translate(image, point.x, point.y, [canvas wraps]);
	origin = NSZeroPoint;
	[self endOptimizedSetting];
	[canvas changedInRect:NSMakeRect(0, 0, [self size].width, [self size].height)];
}

- (void)translateXBy:(float)amountX yBy:(float)amountY
{
	[self moveToPoint:NSMakePoint(origin.x + amountX, origin.y + amountY)];
}

- (void)transformedDrawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(float)frac
{
	if (meldedBezier != nil) {
		PXImage_drawInRectFromRectWithOperationFractionAndMeldedBezier(image, dst, src, op, frac * ([self opacity] / 100.0), meldedBezier, meldedColor);
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

- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(float)frac
{
	if (!visible || opacity == 0) { return; }
	[self transformedDrawInRect:dst fromRect:NSOffsetRect(src, - origin.x, - origin.y) operation:op fraction:frac];
}

//#warning maybye should not be here ? 
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
				// this can probably be optimized with some sort of palette index caching. maybe.
				NSPoint point = NSMakePoint(i, j);
				id color1 = PXImage_colorAtXY(image,point.x,point.y), color2 = PXImage_colorAtXY([aLayer image],point.x,point.y);
				PXImage_setColorAtXY(image,point.x,point.y,((flattenOpacity) ? [color1 colorWithAlphaComponent:[color1 alphaComponent]*([self opacity]/100.00)] : color1));
				PXImage_setColorAtXY([aLayer image],point.x,point.y,((flattenOpacity) ? [color2 colorWithAlphaComponent:[color2 alphaComponent]*([aLayer opacity]/100.00)] : color2));
			}
		}
	}
	PXImage_compositeUnderInRect(image, [aLayer image], aRect, YES);
	if (flattenOpacity) 
	{ 
		[self setOpacity:100]; 
	}
}

- (void)compositeNoBlendUnder:(PXLayer *)aLayer inRect:(NSRect)aRect
{
	PXImage_compositeUnderInRect(image, [aLayer image], aRect, NO);
}

- (NSImage *)exportImage
{
	return PXImage_unpremultipliedCocoaImage(image);
}

- (NSImage *)displayImage
{
	return PXImage_cocoaImage(image);
}

- (void)flipHorizontally
{
	PXImage_flipHorizontally(image);
}

- (void)flipVertically
{
	PXImage_flipVertically(image);
}

-(id) initWithCoder:(NSCoder *)coder
{
	[super init];
	
	image = PXImage_initWithCoder(PXImage_alloc(), coder);
	name = [[coder decodeObjectForKey:@"name"] retain];
	
	visible = YES;
	
	if([coder decodeObjectForKey:@"opacity"] != nil)
	{	
		opacity = [[coder decodeObjectForKey:@"opacity"] doubleValue];
	}
	else
	{
		opacity = 100;
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	PXImage_encodeWithCoder(image, coder);
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:[NSNumber numberWithDouble:opacity] forKey:@"opacity"];
}

- (void)_setImage:(PXImage *)newImage
{
	image = newImage;
}

-(id) copyWithZone:(NSZone *)zone
{
	PXLayer * copy = [[[self class] alloc] initWithName:name image:PXImage_copy(image)];
	PXImage_release([copy image]);
	[copy setCanvas:[self canvas]];
	[copy setOpacity:opacity];
	[copy setVisible:visible];
	return copy;
}

- (void)beginOptimizedSettingWithPremadeImage:(NSImage *)premade
{
	PXImage_beginOptimizedSettingWithPremadeImage(image, premade);
}

- (void)beginOptimizedSetting
{
	PXImage_beginOptimizedSetting(image);
}

- (void)endOptimizedSetting
{
	PXImage_endOptimizedSetting(image);
}

//- (void)setUndoManager:(NSUndoManager *)man
//{
//	undoManager = man;
//}
//
//- (void)modifyColorIndices:(NSArray *)indices by:(int)delta
//{
//	[[undoManager prepareWithInvocationTarget:self] modifyColorIndices:indices by:-1 * delta];
//	id enumerator = [indices objectEnumerator], current;
//	while(current = [enumerator nextObject])
//	{
//		int val = [current intValue];
//		[self setColorIndex:[self colorIndexAtIndex:val] + delta atIndex:val];
//	}	
//}
//
//- (void)decrementColorIndices:(NSArray *)indices
//{
//	[self modifyColorIndices:indices by:-1];
//}
//
//- (void)incrementColorIndices:(NSArray *)indices
//{
//	[self modifyColorIndices:indices by:1];
//}

- (void)paletteChanged:note
{
	PXPalette *pal = [[note object] pointerValue];
	NSDictionary *userInfo = [note userInfo];
	NSString *noteName = [userInfo objectForKey:PXSubNotificationNameKey];
	if(pal == image->palette)
	{
		if([noteName isEqual:PXPaletteRemovedColorNotificationName])
		{
			//note - if it's possible to remove colors from the middle of the palette, this being commented out will break things unless we keep the palette's size constant.
			//it was commented out because it made for HIDEOUS BUGS with undo/redo of changed palette colors and some other things.
//			int maxIndex = [[userInfo objectForKey:PXChangedIndexKey] unsignedIntValue];
//			NSMutableArray *indices = [NSMutableArray arrayWithCapacity:10000];
//			int max = [self size].width * [self size].height;
//			int i;
//			for(i = 0; i < max; i++)
//			{
//				if(PXImage_colorIndexAtIndex(image,i) > maxIndex)
//				{
//					[indices addObject:[NSNumber numberWithInt:i]];
//				}
//			}
//			[[undoManager prepareWithInvocationTarget:self] incrementColorIndices:indices];
//			[self decrementColorIndices:indices];
		}
		else if([noteName isEqual:PXPaletteAddedColorNotificationName])
		{
			return; // don't recache or update the image, that's way too slow
		}
		else if([noteName isEqual:PXPaletteMovedColorNotificationName])
		{
			if([[userInfo objectForKey:PXAdjustIndicesKey] boolValue])
			{
				PXImage_colorAtIndexMovedToIndex(image, [[userInfo objectForKey:PXChangedIndexKey] unsignedIntValue], [[userInfo objectForKey:PXSourceIndexKey] unsignedIntValue]);
				return;
			}
		}
		PXImage_recache(image);
		[canvas changed];
	}
}

- (void)recache
{
	PXImage_recache(image);
}

- (void)setPalette:(PXPalette *)palette recache:(BOOL)recache
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	PXImage_setPaletteRecaching(image, palette, recache);
	[nc addObserver:self
		   selector:@selector(paletteChanged:)
			   name:PXPaletteChangedNotificationName
			 object:nil];
}

- (void)setPalette:(PXPalette *)palette
{
	[self setPalette:palette recache:YES];
}

- (PXLayer *)layerAfterApplyingMove
{
	PXLayer *newLayer = [[self copy] autorelease];
	PXImage_setSize(newLayer->image, [self size], [self origin], [canvas eraseColorIndex]);
	return newLayer;
}

- (void)applyImage:(NSImage *)anImage
{
	int i = 0, j = 0;
	NSPoint point = NSZeroPoint, dest = NSZeroPoint;
	Class colorClass = [NSCalibratedRGBColor class];
	id imageRep = [[anImage representations] objectAtIndex:0];
	if (![imageRep isKindOfClass:[NSBitmapImageRep class]])
	{
		[anImage lockFocus];
		id oldRep = imageRep;
		imageRep = [NSBitmapImageRep imageRepWithData:[anImage TIFFRepresentation]];
		[anImage unlockFocus];
		[anImage removeRepresentation:oldRep];
		[anImage addRepresentation:imageRep];
		
	}
	
	[self beginOptimizedSettingWithPremadeImage:anImage];
	imageRep = [[PXImage_cocoaImage([self image]) representations] objectAtIndex:0];
	unsigned char * bitmapData = [imageRep bitmapData];
	
	BOOL hasAlpha = ([imageRep samplesPerPixel] > 3);
	int width = floorf([anImage size].width);
	int height = floorf([anImage size].height);
	unsigned long long baseIndex;
	NSAutoreleasePool *pool;
	id color;
	int bytesPerRow = [imageRep bytesPerRow];
	for(j = 0; j < height; j++)
	{
		point.y = j;
		dest.y = height - j - 1;
		pool = [[NSAutoreleasePool alloc] init];
		for(i = 0; i < width; i++)
		{
			point.x = i;
			dest.x = i;
			if (hasAlpha)
			{
				baseIndex = (j * bytesPerRow) + i*4;
				color = [[colorClass allocWithZone:[self zone]] initWithRed:bitmapData[baseIndex + 0] / 255.0f
																				green:bitmapData[baseIndex + 1] / 255.0f
																				 blue:bitmapData[baseIndex + 2] / 255.0f
																				alpha:bitmapData[baseIndex + 3] / 255.0f];
			}
			else
			{
				baseIndex = (j * bytesPerRow) + i*3;
				color = [[colorClass allocWithZone:[self zone]] initWithRed:bitmapData[baseIndex + 0] / 255.0f
																				green:bitmapData[baseIndex + 1] / 255.0f
																				 blue:bitmapData[baseIndex + 2] / 255.0f
																	  alpha:1];
			}
			[self setColor:color atPoint:dest];
			[color release];
		}
		[pool release];
	}
	[self endOptimizedSetting];
	PXImage_recache(image);
}

- (void)removeColorIndicesAfter:(unsigned)index
{
	PXImage_removeColorIndicesAfter(image, index);
	PXImage_recache(image);
}

- (void)adaptToPaletteWithTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor
{
	id outputImage = [[[self displayImage] copy] autorelease];
	id rep = [NSBitmapImageRep imageRepWithData:[outputImage TIFFRepresentation]];
	unsigned char *bitmapData = [rep bitmapData];
	int i;
	id calibratedClear = [[NSColor clearColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	for (i = 0; i < [self size].width * [self size].height; i++)
	{
		int base = i * 4;
		NSColor *color;
		if (bitmapData[base + 3] == 0 && transparency)
		{
			color = calibratedClear;
		}
		else if (bitmapData[base + 3] < 255 && matteColor)
		{
			NSColor *sourceColor = [NSColor colorWithCalibratedRed:bitmapData[base + 0] / 255.0f green:bitmapData[base + 1] / 255.0f blue:bitmapData[base + 2] / 255.0f alpha:1];
			color = [matteColor blendedColorWithFraction:(bitmapData[base + 3] / 255.0f) ofColor:sourceColor];
		}
		else
		{
			color = [NSColor colorWithCalibratedRed:bitmapData[base + 0] / 255.0f green:bitmapData[base + 1] / 255.0f blue:bitmapData[base + 2] / 255.0f alpha:1];
		}
		[self setColorIndex:PXPalette_indexOfColorClosestTo([canvas palette], color) atIndex:i];
	}
}

@end
