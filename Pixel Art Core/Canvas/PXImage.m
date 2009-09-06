//
//  PXImage.m
//  Pixen-XCode
//
// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//  Created by Joe Osborn on Tue Oct 28 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import "PXImage.h"

PXImage *PXImage_alloc()
{
	PXImage *image = (PXImage *)malloc(sizeof(PXImage));
	image->retainCount = 1;
	return image;
}

PXImage *PXImage_init(PXImage *self)
{
	self->palette = nil; // the palette is always set externally
	self->width = 0;
	self->height = 0;
	self->usingPremadeImage = NO;
	self->cachedSourceOutImage = nil;
	self->isBlank = YES;
	self->premultipliesAlpha = YES;
	return self;
}

void PXImage_encodeWithCoder(PXImage *self, NSCoder *coder)
{
	id dict = [NSMutableDictionary dictionaryWithCapacity:4];
	[dict setObject:[NSNumber numberWithInt:(self->width)] forKey:@"width"];
	[dict setObject:[NSNumber numberWithInt:(self->height)] forKey:@"height"];
	[dict setObject:[NSData dataWithBytes:self->colorIndices length:(self->width * self->height * sizeof(unsigned int))] forKey:@"colorIndices"];
	[coder encodeObject:dict forKey:@"image"];
}

PXImage *PXImage_initWithCoder(PXImage *self, NSCoder *coder)
{
	PXImage_init(self);
	NSDictionary *dict = [coder decodeObjectForKey:@"image"];
	self->width = [[dict objectForKey:@"width"] intValue];
	self->height = [[dict objectForKey:@"height"] intValue];
	self->image = [[NSImage alloc] initWithSize:NSMakeSize(self->width, self->height)];
	self->colorIndices = (unsigned int *)malloc(sizeof(unsigned int) * self->width * self->height);
	memcpy(self->colorIndices, [[dict objectForKey:@"colorIndices"] bytes], sizeof(unsigned int) * self->width * self->height);
	self->isBlank = NO;
	return self;
}

PXImage *PXImage_initWithSize(PXImage *self, NSSize size)
{
	PXImage_init(self);
	self->image = [[NSImage alloc] initWithSize:size];
	self->width = size.width;
	self->height = size.height;
	self->colorIndices = (unsigned int *)malloc(sizeof(unsigned int) * self->width * self->height);
	memset(self->colorIndices, 0, sizeof(unsigned int) * self->width * self->height);
	PXImage_bitmapifyCachedImage(self);
	return self;
}

void PXImage_dealloc(PXImage *self)
{
	if (self->width * self->height > 0) {
		free(self->colorIndices);
	}
	[self->cachedSourceOutImage release];
	[self->image release];
	free(self);
}

PXImage *PXImage_copy(PXImage *self)
{
	PXImage *image = PXImage_init(PXImage_alloc());
	image->palette = self->palette;
	image->image = [self->image copy];
	image->width = self->width;
	image->height = self->height;
	image->colorIndices = (unsigned int *)malloc(sizeof(unsigned int) * image->width * image->height);
	image->isBlank = self->isBlank;
	memcpy(image->colorIndices, self->colorIndices, sizeof(unsigned int) * image->width * image->height);
	PXImage_bitmapifyCachedImage(image);
	return image;
}

PXImage *PXImage_retain(PXImage *self)
{
	if (self == nil) {
		return self;
	}
	self->retainCount++;
	return self;
}

PXImage *PXImage_release(PXImage *self)
{
	if (self == nil) {
		return self;
	}
	self->retainCount--;
	if (self->retainCount <= 0) {
		PXImage_dealloc(self);
	}
	return self;
}

unsigned int PXImage_colorIndexAtXY(PXImage *self, int xLoc, int yLoc)
{
	int x = xLoc, y = yLoc;
	if(xLoc < 0 ||
	   xLoc >= self->width ||
	   yLoc < 0 ||
	   yLoc >= self->height)
	{
		return 0;
	}
	return self->colorIndices[x + (y * self->width)];
}

NSColor *PXImage_colorAtXY(PXImage *self, int x, int y)
{
	if (self->palette != nil) {
		return self->palette->colors[PXImage_colorIndexAtXY(self, x, y)];
	} else {
		return [NSColor clearColor];
	}
}

unsigned int PXImage_colorIndexAtIndex(PXImage *self, unsigned loc)
{
	int xLoc = loc % self->width;
	int yLoc = (loc - (loc % self->width))/self->width;
	return PXImage_colorIndexAtXY(self, xLoc, self->height - yLoc - 1);
}

void PXImage_setColorIndexAtIndex(PXImage *self, unsigned index, unsigned loc)
{
	int xLoc = loc % self->width;
	int yLoc = (loc - (loc % self->width))/self->width;
	PXImage_setColorIndexAtXY(self, xLoc, self->height - yLoc - 1, index);

}

#ifndef NSAppKitVersionNumber10_3  
#define NSAppKitVersionNumber10_3 743  
#endif

void PXImage_beginOptimizedSettingWithPremadeImage(PXImage *self, NSImage *premade)
{
	[premade retain];
	[self->image release];
	self->image = premade;
	PXImage_bitmapifyCachedImage(self);
	if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_3)
	{
		[self->image autorelease];
		self->image = PXImage_unpremultipliedCocoaImage(self);
	}
	else
	{
		if (!([[[[self->image representations] objectAtIndex:0] valueForKey:@"bitmapFormat"] intValue] & 2)) // 2 = NSAlphaNonpremultipliedBitmapFormat
		{
			// This image is premultiplied.
			[self->image autorelease];
			self->image = [PXImage_unpremultipliedCocoaImage(self) retain];
		}
		else
		{
			id oldRep = [[self->image representations] objectAtIndex:0];
			unsigned char *data = malloc([oldRep bytesPerRow] * self->height);
			memcpy(data, [oldRep bitmapData], [oldRep bytesPerRow] * self->height);
			NSBitmapImageRep *newRep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&data pixelsWide:self->width pixelsHigh:self->height bitsPerSample:[oldRep bitsPerSample] samplesPerPixel:[oldRep samplesPerPixel] hasAlpha:[oldRep hasAlpha] isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:[oldRep bytesPerRow] bitsPerPixel:[oldRep bitsPerPixel]] autorelease];
			[self->image removeRepresentation:oldRep];
			[self->image addRepresentation:newRep];
		}
	}
	PXImage_bitmapifyCachedImage(self);
	self->usingPremadeImage = YES;
	PXPalette_postponeNotifications(self->palette, YES);
}

void PXImage_beginOptimizedSetting(PXImage *self)
{
	PXPalette_postponeNotifications(self->palette, YES);
}

void PXImage_endOptimizedSetting(PXImage *self)
{
	if (self->usingPremadeImage) {
		self->usingPremadeImage = NO;
		self->palette->postedNotificationWhilePostponing = NO; // don't recache!
	}
	PXPalette_postponeNotifications(self->palette, NO);
}

void PXImage_setPremultipliesAlpha(PXImage *self, BOOL premults)
{
	self->premultipliesAlpha = premults;
}

#define int_multiply(a, b, temp)  ((temp) = (a) * (b) + 0x80, ((((temp) >> 8) + (temp)) >> 8))

void PXImage_setImageColorIndexAtXY(PXImage *self, int xLoc, int yLoc, unsigned int index)
{
	if (index >= self->palette->colorCount) { return; }
	NSColor *color = self->palette->colors[index];
	if (!self->cachedBitmapRep) {
		PXImage_bitmapifyCachedImage(self);
	}
	NSBitmapImageRep *rep = self->cachedBitmapRep;
	int samplesPerPixel = [rep samplesPerPixel];
	int bytesPerRow = [rep bytesPerRow];
	unsigned char *bitmapData = [rep bitmapData];
	yLoc = (self->height - yLoc - 1);
	int temp;
	int red = [color redComponent] * 255;
	int green = [color greenComponent] * 255;
	int blue = [color blueComponent] * 255;
	float alpha = [color alphaComponent];
	unsigned char scaledAlpha = alpha * 255;
	
	if (self->premultipliesAlpha)
	{
		red = int_multiply(red, scaledAlpha, temp);
		green = int_multiply(green, scaledAlpha, temp);
		blue = int_multiply(blue, scaledAlpha, temp);
	}
	bitmapData[(yLoc * bytesPerRow) + xLoc * samplesPerPixel + 0] = red;
	bitmapData[(yLoc * bytesPerRow) + xLoc * samplesPerPixel + 1] = green;
	bitmapData[(yLoc * bytesPerRow) + xLoc * samplesPerPixel + 2] = blue;
	if ([rep hasAlpha])
		bitmapData[(yLoc * bytesPerRow) + xLoc * samplesPerPixel + 3] = scaledAlpha;
}

void PXImage_setColorIndexAtXY(PXImage *self, int xLoc, int yLoc, unsigned int index)
{
	int x = xLoc, y = yLoc;
	if(xLoc < 0 ||
	   xLoc >= self->width ||
	   yLoc < 0 ||
	   yLoc >= self->height)
	{
		return;
	}
	
	// This check makes images with transparency totally flip out. I think we're doing more work than we should be, but, uh, it works.
	//if (!self->usingPremadeImage) {
		PXImage_setImageColorIndexAtXY(self, xLoc, yLoc, index);
	//}
	self->colorIndices[x + y * self->width] = index;
	self->isBlank = NO;
}

void PXImage_removeColorIndicesAfter(PXImage *self, unsigned int index)
{
	int i;
	for (i=0; i<self->width*self->height; i++) {
		if (self->colorIndices[i] > index) {
			self->colorIndices[i] = 0;
		}
	}
}

void _PXImage_modifyColorIndices(PXImage *self, NSArray *indices, int delta)
{
	id enumerator = [indices objectEnumerator], current;
	while(current = [enumerator nextObject])
	{
		self->colorIndices[[current unsignedIntValue]] += delta;
	}
}

void PXImage_incrementColorIndices(PXImage *self, NSArray *indices)
{
	_PXImage_modifyColorIndices(self, indices, 1);
}

void PXImage_decrementColorIndices(PXImage *self, NSArray *indices)
{
	_PXImage_modifyColorIndices(self, indices, -1);
}

void PXImage_setColorAtXY(PXImage *self, int x, int y, NSColor *color)
{
	if (self->palette == NULL) {
		return;
	}
	PXImage_setColorIndexAtXY(self, x, y, PXPalette_indexOfColorAddingIfNotPresent(self->palette, color));
}

void PXImage_flipHorizontally(PXImage *self)
{
	unsigned int leftColorIndex, rightColorIndex;
	int x, y;
	for (y=0; y<self->height; y++) {
		for (x=0; x<self->width/2; x++) {
			leftColorIndex = PXImage_colorIndexAtXY(self, x, y);
			rightColorIndex = PXImage_colorIndexAtXY(self, self->width - x - 1, y);
			PXImage_setColorIndexAtXY(self, x, y, rightColorIndex);
			PXImage_setColorIndexAtXY(self, self->width - x - 1, y, leftColorIndex);
		}
	}
}

void PXImage_flipVertically(PXImage *self)
{
	unsigned int leftColorIndex, rightColorIndex;
	int x, y;
	for (y=0; y<self->height/2; y++) {
		for (x=0; x<self->width; x++) {
			leftColorIndex = PXImage_colorIndexAtXY(self, x, y);
			rightColorIndex = PXImage_colorIndexAtXY(self, x, self->height - y - 1);
			PXImage_setColorIndexAtXY(self, x, y, rightColorIndex);
			PXImage_setColorIndexAtXY(self, x, self->height - y - 1, leftColorIndex);
		}
	}
}

#define WRAP(thing) {\
	while(x##thing < 0) { x##thing += self->width; }\
	while(y##thing < 0) { y##thing += self->height; }\
	if(x##thing >= self->width) { x##thing -= self->width; }\
	if(y##thing >= self->height) { y##thing -= self->height; }\
}	

void PXImage_translate(PXImage *self, int deltaX, int deltaY, BOOL wrap)
{
	PXImage *copy = PXImage_copy(self);
	int startX=0, startY=0, endX=self->width-1, endY=self->height-1, x, y;
	int directionX=1, directionY=1;
	if (deltaX > 0) {
		startX = endX;
		endX = 0;
		directionX *= -1;
	}
	if (deltaY > 0) {
		startY = endY;
		endY = 0;
		directionY *= -1;
	}
	for (y=startY; y*directionY <= endY*directionY; y+=directionY) {
		for (x=startX; x*directionX <= endX*directionX; x+=directionX) {
			int xDst = x, yDst = y, xSrc = x-deltaX, ySrc = y-deltaY;
			if(wrap)
			{
				WRAP(Dst)
				WRAP(Src)
			}
			PXImage_setColorIndexAtXY(self, xDst, yDst, PXImage_colorIndexAtXY(copy, xSrc, ySrc));
		}
	}
	PXImage_release(copy);
}

// backgroundColor is a palette offset
void PXImage_setSize(PXImage *self, NSSize newSize, NSPoint origin, int backgroundColor)
{
	if (self->palette == nil) {
		return;
	}
	int i, j;
	int newWidth = newSize.width, newHeight = newSize.height;
	int originX = origin.x, originY = origin.y;
	unsigned int *newColors = (unsigned int *)malloc(newWidth * newHeight * sizeof(unsigned int));
	for (i=0; i < newWidth; i++) {
		for (j=0; j < newHeight; j++) {
			if (i < originX || j < originY || 
				i >= self->width + originX || j >= self->height + originY) {
				newColors[i + j * newWidth] = backgroundColor;
			} else {
				newColors[i + j * newWidth] = PXImage_colorIndexAtXY(self, i-originX, j-originY);
			}
		}
	}
	self->width = newWidth;
	self->height = newHeight;
	free(self->colorIndices);
	self->colorIndices = newColors;
	NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
	[newImage lockFocus];
	[self->palette->colors[backgroundColor] set];
	NSRectFillUsingOperation(NSMakeRect(0, 0, newSize.width, newSize.height), NSCompositeCopy);
	[self->image compositeToPoint:origin operation:NSCompositeSourceOver];
	[newImage unlockFocus];
	[self->image release];
	self->image = newImage;
	PXImage_bitmapifyCachedImage(self);
}

void PXImage_rotateByDegrees(PXImage *self, int degrees)
{
	if (degrees != 90 && degrees != 180 && degrees != 270) { return; } // only support orthogonal rotation
	int i, j;
	unsigned int *oldIndices = (unsigned int *)malloc(sizeof(unsigned int) * self->width * self->height);
	memcpy(oldIndices, self->colorIndices, sizeof(unsigned int) * self->width * self->height);
	
	// update our size if necessary
	int oldWidth = self->width;
	int oldHeight = self->height;
	if (degrees != 180)
	{
		self->height = oldWidth;
		self->width = oldHeight;
		[self->image release];
		self->image = [[NSImage alloc] initWithSize:NSMakeSize(self->width, self->height)];
		PXImage_bitmapifyCachedImage(self);
	}

	PXImage_beginOptimizedSetting(self);
	for (j = 0; j < oldHeight; j++)
	{
		for (i = 0; i < oldWidth; i++)
		{
			int x=0, y=0;
			if (degrees == 270)
			{
				x = j;
				y = self->height - 1 - i;
			}
			else if (degrees == 180)
			{
				x = self->width - 1 - i;
				y = self->height - 1 - j;
			}
			else if (degrees == 90)
			{
				x = self->width - 1 - j;
				y = i;
			}
			PXImage_setColorIndexAtXY(self, x, y, oldIndices[i + j * oldWidth]);
		}
	}
	PXImage_endOptimizedSetting(self);
	free(oldIndices);
}

void PXImage_recache(PXImage *self)
{
	PXImage_bitmapifyCachedImage(self);
	PXImage_beginOptimizedSetting(self);
	int i, j;
	for(i = 0; i < self->width; i++)
	{
		for(j = 0; j < self->height; j++)
		{
			PXImage_setImageColorIndexAtXY(self, i, j, PXImage_colorIndexAtXY(self, i, j));
			/*id color = PXImage_colorAtXY(self,i,j);
			[color set];
			NSRectFillUsingOperation(NSMakeRect(i, j, 1, 1), NSCompositeCopy);*/
		}
	}
	PXImage_endOptimizedSetting(self);
}

void PXImage_setPaletteRecaching(PXImage *self, PXPalette *palette, BOOL recache)
{
	PXPalette *oldPalette = self->palette;
	self->palette = palette;
	if (((oldPalette != NULL) || !self->isBlank) && palette != oldPalette && recache) {
		PXImage_recache(self);
	}	
}

void PXImage_setPalette(PXImage *self, PXPalette *palette)
{
	PXImage_setPaletteRecaching(self, palette, YES);
}

void PXImage_compositeUnderInRect(PXImage *self, PXImage *other, NSRect aRect, BOOL blend)
{
	int i, j;

	NSColor * topColor;
	NSColor * bottomColor;
	NSColor * usedColor;
	
	PXImage_beginOptimizedSetting(self);
    for(i = NSMinX(aRect); i < NSMaxX(aRect); i++)
    {
        for(j = NSMinY(aRect); j < NSMaxY(aRect); j++)
        {
			topColor = PXImage_colorAtXY(other, i, j);
			bottomColor = PXImage_colorAtXY(self, i, j);
			usedColor = topColor;
			
			if (blend) {
				usedColor = PXImage_blendColors(self, bottomColor, topColor);
			}
			if ([usedColor alphaComponent] != 0)
			{
				PXImage_setColorAtXY(self, i, j, usedColor);
			}
        }
    }
	PXImage_endOptimizedSetting(self);
}

void PXImage_compositeUnder(PXImage *self, PXImage *other, BOOL blend)
{
	PXImage_compositeUnderInRect(self, other, NSMakeRect(0,0,self->width,self->height), blend);
}

void PXImage_drawRect(PXImage *self, NSRect rect, double opacity)
{
	PXImage_drawInRectFromRectWithOperationFraction(self, rect, rect, NSCompositeSourceOver, opacity);
}

void PXImage_drawInRectFromRectWithOperationFraction(PXImage *self, NSRect dst, NSRect src, NSCompositingOperation operation, double opacity)
{
	[self->image drawInRect:dst fromRect:src operation:operation fraction:opacity];
}

void PXImage_drawInRectFromRectWithOperationFractionAndMeldedBezier(PXImage *self, NSRect dst, NSRect src, NSCompositingOperation operation, double opacity, NSBezierPath *melded, NSColor *meldedColor)
{
	float widthScale = NSWidth(dst) / NSWidth(src);
	float heightScale = NSHeight(dst) / NSHeight(src);
	NSRect fullDest = dst;
	fullDest.origin.x -= widthScale * (NSMinX(src) - floorf(NSMinX(src)));
	fullDest.origin.y -= heightScale * (NSMinY(src) - floorf(NSMinY(src)));
	fullDest.size.width += widthScale * (ceilf(NSWidth(src)) - NSWidth(src));
	fullDest.size.height += heightScale * (ceilf(NSHeight(src)) - NSHeight(src));
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform scaleXBy:widthScale yBy:heightScale];
	NSBezierPath *path = [transform transformBezierPath:melded];
	if ([meldedColor alphaComponent] == 1) {
		PXImage_drawInRectFromRectWithOperationFraction(self, dst, src, operation, opacity);
	} else {
		if(!self->cachedSourceOutImage || (NSWidth(fullDest) > [self->cachedSourceOutImage size].width) || (NSHeight(fullDest) > [self->cachedSourceOutImage size].height))
		{
			[self->cachedSourceOutImage autorelease];
			self->cachedSourceOutImage = [[NSImage alloc] initWithSize:fullDest.size];
		}
 		NSAffineTransform *translate = [NSAffineTransform transform];
		[translate translateXBy:-1 * rintf(NSMinX(fullDest)) yBy:-1 * rintf(NSMinY(fullDest))];
		[self->cachedSourceOutImage lockFocus];
		[[NSColor clearColor] set];
		NSRectFill(NSMakeRect(0, 0, [self->cachedSourceOutImage size].width, [self->cachedSourceOutImage size].height));
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
		[[NSColor blackColor] set];
		[[translate transformBezierPath:path] fill];
		[self->image drawInRect:NSMakeRect(0, 0, NSWidth(fullDest), NSHeight(fullDest)) fromRect:NSMakeRect(floorf(NSMinX(src)), floorf(NSMinY(src)), ceilf(NSWidth(src)), ceilf(NSHeight(src))) operation:NSCompositeSourceOut fraction:1];
		[self->cachedSourceOutImage unlockFocus];
		
		[self->cachedSourceOutImage compositeToPoint:fullDest.origin operation:operation fraction:opacity];
	}
	[meldedColor set];
	[path fill];
}


NSImage *PXImage_unpremultipliedCocoaImage(PXImage *self)
{
	NSImage *image = PXImage_cocoaImage(self);
	id rep = [[image representations] objectAtIndex:0];	
	unsigned char *newData = malloc([rep bytesPerRow] * self->height);
	unsigned char *oldData = [rep bitmapData];
	int i, j;
	float alphaMultiplier;
	int initialIndex;
	for (j = 0; j < self->height; j++)
	{
		for (i = 0; i < self->width; i++)
		{
			initialIndex = j*[rep bytesPerRow] + i*4;
			alphaMultiplier = 255.0 / oldData[initialIndex + 3];
			newData[initialIndex + 0] = MIN(ceilf(oldData[initialIndex + 0] * alphaMultiplier), 255);
			newData[initialIndex + 1] = MIN(ceilf(oldData[initialIndex + 1] * alphaMultiplier), 255);
			newData[initialIndex + 2] = MIN(ceilf(oldData[initialIndex + 2] * alphaMultiplier), 255);
			newData[initialIndex + 3] = oldData[initialIndex + 3];
		}
	}
	NSBitmapImageRep *imageRep;
	imageRep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&newData pixelsWide:self->width pixelsHigh:self->height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:[rep bytesPerRow] bitsPerPixel:32] autorelease];
	NSImage *newImage = [[[NSImage alloc] initWithSize:NSMakeSize(self->width, self->height)] autorelease];
	[newImage addRepresentation:imageRep];
	return newImage;
}

void PXImage_bitmapifyCachedImage(PXImage *self)
{
	if ([[self->image representations] count] == 0)
	{
		NSSize imageSize = NSMakeSize(self->width, self->height);
		NSImage *tempImage = [[[NSImage alloc] initWithSize:imageSize] autorelease];
		[tempImage lockFocus];
		[[NSColor clearColor] set];
		NSRectFill((NSRect){NSZeroPoint, imageSize});
		[tempImage unlockFocus];
		[self->image addRepresentation:[NSBitmapImageRep imageRepWithData:[tempImage TIFFRepresentation]]];
	}
	id rep = [[self->image representations] objectAtIndex:0];
	if (![rep isKindOfClass:[NSBitmapImageRep class]])
	{
		NSLog(@"Converting cached to bitmap...");
		NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[self->image TIFFRepresentation]];
		
		[self->image removeRepresentation:rep];
		[self->image addRepresentation:imageRep];
	}
	rep = [[self->image representations] objectAtIndex:0]; // could be different now.
	if (![rep hasAlpha])
	{
		unsigned char * newData = malloc(self->width * self->height * 4);
		NSBitmapImageRep *tempRep = [NSBitmapImageRep imageRepWithData:[rep TIFFRepresentation]];
		unsigned char * oldData = [tempRep bitmapData];
		int i, j;
		NSSize imageSize = NSMakeSize([tempRep pixelsWide], [tempRep pixelsHigh]);
		int bytesPerRow = [tempRep bytesPerRow];
		int samplesPerPixel = [tempRep samplesPerPixel];
		for (j = 0; j < imageSize.height; j++)
		{
			for (i = 0; i < imageSize.width; i++)
			{
				int oldBase = j * bytesPerRow + i * samplesPerPixel;
				int newBase = j * 4 * self->width + i * 4;
				newData[newBase + 0] = oldData[oldBase + 0];
				newData[newBase + 1] = oldData[oldBase + 1];
				newData[newBase + 2] = oldData[oldBase + 2];
				newData[newBase + 3] = 255;
			}
		}
		id imageRep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&newData pixelsWide:self->width pixelsHigh:self->height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:self->width * 4 bitsPerPixel:32] autorelease];
		[self->image removeRepresentation:rep];
		[self->image addRepresentation:imageRep];
	}
	rep = [[self->image representations] objectAtIndex:0]; // could be different now.
	
//#warning UH THIS MIGHT NOT WORK IN PANTHER
	if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_3)
	{
		if ([[rep valueForKey:@"bitmapFormat"] intValue] & 1) // == argb instead of rgba
		{
			unsigned char *bitmapData = [rep bitmapData];
			int i, j;
			for (j = 0; j < self->height; j++)
			{
				for (i = 0; i < self->width; i++)
				{
					int baseIndex = j * [rep bytesPerRow] + i*4;
					unsigned char temp;
					temp = bitmapData[baseIndex];
					bitmapData[baseIndex] = bitmapData[baseIndex+1];
					bitmapData[baseIndex+1] = bitmapData[baseIndex+2];
					bitmapData[baseIndex+2] = bitmapData[baseIndex+3];
					bitmapData[baseIndex+3] = temp;
				}
			}
		}
	}
	self->cachedBitmapRep = rep;
}

NSImage *PXImage_cocoaImage(PXImage *self)
{
	if (self->cachedBitmapRep == nil) {
		PXImage_bitmapifyCachedImage(self);
	}
	return self->image;
}

NSColor * PXImage_blendColors(PXImage * self, NSColor * bottomColor, NSColor * topColor)
{
	bottomColor = [bottomColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	topColor = [topColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	float compositeRedComponent;
	float compositeGreenComponent;
	float compositeBlueComponent;
	float compositeAlphaComponent;
	float topBlueComponent = [topColor blueComponent];
	float topRedComponent = [topColor redComponent];
	float topGreenComponent = [topColor greenComponent];
	float topAlphaComponent = [topColor alphaComponent];
	float bottomBlueComponent = [bottomColor blueComponent];
	float bottomRedComponent = [bottomColor redComponent];
	float bottomGreenComponent = [bottomColor greenComponent];
	float bottomAlphaComponent = [bottomColor alphaComponent];			
	compositeAlphaComponent = topAlphaComponent + bottomAlphaComponent - (topAlphaComponent * bottomAlphaComponent);
	if(compositeAlphaComponent == 0)
	{
		return [[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	}
	else
	{	
		compositeRedComponent = bottomRedComponent + ((topRedComponent - bottomRedComponent) * (topAlphaComponent / compositeAlphaComponent));
		compositeBlueComponent = bottomBlueComponent + ((topBlueComponent - bottomBlueComponent) * (topAlphaComponent / compositeAlphaComponent));
		compositeGreenComponent = bottomGreenComponent + ((topGreenComponent - bottomGreenComponent) * (topAlphaComponent / compositeAlphaComponent));
		return [[NSColor colorWithDeviceRed:compositeRedComponent green:compositeGreenComponent blue:compositeBlueComponent alpha:compositeAlphaComponent] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	}	
}

void PXImage_colorAtIndexMovedToIndex(PXImage *self, unsigned source, unsigned dest)
{
	if(dest == source) { return; }
	unsigned int *colorIndices = self->colorIndices;
	int i;
	if(source > dest)
	{
		for(i = 0; i < self->width * self->height; i++)
		{
			if(colorIndices[i] == dest)
			{
				colorIndices[i] = source;
			}
			else if(colorIndices[i] > dest)
			{
				colorIndices[i]--;
			}
		}		
	}
	else
	{
		for(i = 0; i < self->width * self->height; i++)
		{
			if(colorIndices[i] == dest)
			{
				colorIndices[i] = source;
			}
			else if(colorIndices[i] < dest)
			{
				colorIndices[i]++;
			}
		}		
	}
}
