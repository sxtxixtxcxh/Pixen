//
//  PXImageBackground.h
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


#import <AppKit/AppKit.h>
#import "PXPalette.h"

typedef struct {
	int retainCount;
	unsigned int *colorIndices;
	int width, height;
	PXPalette *palette;
	
	NSImage *image, *cachedSourceOutImage;
	NSBitmapImageRep *cachedBitmapRep;
	BOOL usingPremadeImage;
	BOOL isBlank;
	BOOL premultipliesAlpha;
} PXImage;

PXImage *PXImage_alloc();

PXImage *PXImage_init(PXImage *self);
PXImage *PXImage_initWithSize(PXImage *self, NSSize size);
void PXImage_dealloc(PXImage *self);
PXImage *PXImage_copy(PXImage *self);
PXImage *PXImage_retain(PXImage *self);
PXImage *PXImage_release(PXImage *self);

void PXImage_recache(PXImage *self);

void PXImage_beginOptimizedSettingWithPremadeImage(PXImage *self, NSImage *premade);
void PXImage_beginOptimizedSetting(PXImage *self);
void PXImage_endOptimizedSetting(PXImage *self);

unsigned int PXImage_colorIndexAtXY(PXImage *self, int x, int y);
NSColor *PXImage_colorAtXY(PXImage *self, int x, int y);
void PXImage_setColorIndexAtXY(PXImage *self, int x, int y, unsigned int index);
void PXImage_setColorAtXY(PXImage *self, int x, int y, NSColor *color);
void PXImage_setColorIndexAtIndex(PXImage *self, unsigned index, unsigned loc);
void PXImage_incrementColorIndices(PXImage *self, NSArray *indices);
void PXImage_decrementColorIndices(PXImage *self, NSArray *indices);
void PXImage_removeColorIndicesAfter(PXImage *self, unsigned int index);
unsigned int PXImage_colorIndexAtIndex(PXImage *self, unsigned loc);

void PXImage_flipHorizontally(PXImage *self);
void PXImage_flipVertically(PXImage *self);
void PXImage_translate(PXImage *self, int deltaX, int deltaY, BOOL wrap);
void PXImage_rotateByDegrees(PXImage *self, int degrees);

void PXImage_setPaletteRecaching(PXImage *self, PXPalette *palette, BOOL recache);
void PXImage_setPalette(PXImage *self, PXPalette *palette);
void PXImage_setSize(PXImage *self, NSSize newSize, NSPoint origin, int backgroundColorIndex);
void PXImage_setPremultipliesAlpha(PXImage *self, BOOL premults);

void PXImage_drawInRectFromRectWithOperationFractionAndMeldedBezier(PXImage *self, NSRect dst, NSRect src, NSCompositingOperation operation, double opacity, NSBezierPath *melded, NSColor *meldedColor);
void PXImage_drawInRectFromRectWithOperationFraction(PXImage *self, NSRect dst, NSRect src, NSCompositingOperation operation, double opacity);
void PXImage_compositeUnder(PXImage *self, PXImage *other, BOOL blend);
void PXImage_compositeUnderInRect(PXImage *self, PXImage *other, NSRect aRect, BOOL blend);

NSColor * PXImage_blendColors(PXImage * self, NSColor * bottomColor, NSColor * topColor);

void PXImage_bitmapifyCachedImage(PXImage *self);
NSImage *PXImage_cocoaImage(PXImage *self);
NSImage *PXImage_unpremultipliedCocoaImage(PXImage *self);

NSData *PXImage_encodedData(PXImage *self);
PXImage *PXImage_initWithData(PXImage *self, NSData *data);

PXImage *PXImage_initWithCoder(PXImage *self, NSCoder *coder);
void PXImage_encodeWithCoder(PXImage *self, NSCoder *coder);

void PXImage_colorAtIndexMovedToIndex(PXImage *self, unsigned dest, unsigned source);
