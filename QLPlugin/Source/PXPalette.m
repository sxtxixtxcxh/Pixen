//
//  PXPalette.m
//  Pixen-XCode

// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy

// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation 
// the rights  to use,copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom
//  the Software is  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "PXPalette.h"
#import "NSColor+PXPaletteAdditions.h"

PXColorBucket *PXColorBucket_alloc(void);
PXColorBucket *PXColorBucket_init(PXColorBucket *self, NSColor *color, NSUInteger index);
void PXColorBucket_dealloc(PXColorBucket *self);
void PXPalette_insertColorBucket(PXPalette *self, PXColorBucket *bucket);
void PXPalette_removeBucketForColor(PXPalette *self, NSColor *color);
NSColor *_PXPalette_correctColor(NSColor *color);

PXPalette *PXPalette_initWithoutBackgroundColor(PXPalette *self);
PXPalette *PXPalette_initWithDictionary(PXPalette *self, NSDictionary *dict);
void PXPalette_dealloc(PXPalette *self);
PXPalette *PXPalette_retain(PXPalette *self);
PXPalette *PXPalette_release(PXPalette *self);

NSString *PXPalette_name(PXPalette *self);
void PXPalette_setName(PXPalette *self, NSString *name);

void PXPalette_resize(PXPalette *self, NSUInteger newSize);
void PXPalette_addColorPair(PXPalette *self, PXPaletteColorPair pair);
void PXPalette_addColor(PXPalette *self, NSColor *color);
PXColorBucket *PXPalette_bucketForColor(PXPalette *self, NSColor *color);

PXColorBucket *PXColorBucket_alloc()
{
	return (PXColorBucket *)calloc(1, sizeof(PXColorBucket));
}

PXColorBucket *PXColorBucket_init(PXColorBucket *self, NSColor *color, NSUInteger index)
{
	self->next = NULL;
	self->color = [color retain];
	self->index = index;
	return self;
}

void PXColorBucket_dealloc(PXColorBucket *self)
{
	if(!self) {
		return;
	}
	if (self->next != NULL) {
		PXColorBucket_dealloc(self->next);
		self->next = NULL;
	}
	if(self->color) {
		[self->color release];
	}
	free(self);
}

/////////////////////// BUCKET METHODS ///////////////////////

void PXPalette_insertColorBucket(PXPalette *self, PXColorBucket *bucket)
{
	unsigned int hash = [bucket->color paletteHash];
	bucket->next = self->reverseHashTable[hash];
	self->reverseHashTable[hash] = bucket;
}

PXColorBucket *PXPalette_bucketForColor(PXPalette *self, NSColor *color)
{
	unsigned int hash = [color paletteHash];
	PXColorBucket *bucket = self->reverseHashTable[hash];
	while (bucket != NULL && ![color isEqual:bucket->color]) {
		bucket = bucket->next;
	}
	return bucket;
}

void PXPalette_removeBucketForColor(PXPalette *self, NSColor *color)
{
	unsigned int hash = [color paletteHash];
	PXColorBucket *bucket = self->reverseHashTable[hash];
	PXColorBucket *prevBucket = NULL;
	while (bucket != NULL && ![bucket->color isEqual:color]) {
		prevBucket = bucket;
		bucket = bucket->next;
	}
	if (bucket != NULL) {
		if (prevBucket == NULL) {
			self->reverseHashTable[hash] = bucket->next;
		} else {
			prevBucket->next = bucket->next;
		}
		bucket->next = NULL;
		PXColorBucket_dealloc(bucket);
	}
}

//////////////////////////////////////////////////////////////


NSColor *_PXPalette_correctColor(NSColor *color)
{
	NSColor *colorToCheck = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	if ([colorToCheck alphaComponent] == 0) {
		colorToCheck = [[NSColor clearColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]; // so we don't get lots of clear colors
	}
	return colorToCheck;
}

PXPalette *PXPalette_initWithDictionary(PXPalette *self, NSDictionary *dict)
{
	PXPalette_initWithoutBackgroundColor(self);
	PXPalette_setName(self, [dict objectForKey:@"name"]);
	PXPalette_resize(self, [[dict objectForKey:@"size"] intValue]);
	for (id current in [dict objectForKey:@"colors"])
	{
		PXPalette_addColor(self, current);
	}
	return self;
}

PXPalette *PXPalette_alloc()
{
	PXPalette *palette = (PXPalette *)calloc(1, sizeof(PXPalette));
	palette->retainCount = 1;
	return palette;
}

void PXPalette_dealloc(PXPalette *self)
{
	int i;
	if(self->reverseHashTable) {
		for (i=0; i<65536; i++) {
			if (self->reverseHashTable[i] != NULL) {
				PXColorBucket_dealloc(self->reverseHashTable[i]);
			}
		}
		free(self->reverseHashTable);
		self->reverseHashTable = nil;
	}
	if(self->colors) {
		for (i = 0; i < self->size; i++)
		{
			if(self->colors[i].color)
			{
				[self->colors[i].color release];
			}
		}
		free(self->colors);		
		self->colors = nil;
	}
	if(self->name) {		
		[self->name release];
		self->name = nil;
	}
	free(self);
}

PXPalette *PXPalette_initWithoutBackgroundColor(PXPalette *self)
{
	self->canSave = NO;
	self->isSystemPalette = NO;
	self->size = 0;
	self->colorCount = 0;
	self->reverseHashTable = (PXColorBucket **)calloc(65536, sizeof(PXColorBucket *));
	self->name = @"";
	return self;
}

PXPalette *PXPalette_initWithCoder(PXPalette *self, NSCoder *coder)
{
	return PXPalette_initWithDictionary(self, [coder decodeObjectForKey:@"palette"]);
}

PXPalette *PXPalette_retain(PXPalette *self)
{
	if(!self)
	{
		return NULL;
	}
	self->retainCount++;
	return self;
}

PXPalette *PXPalette_release(PXPalette *self)
{
	if(!self) { return NULL; }
	self->retainCount--;
	if (self->retainCount <= 0) {
		PXPalette_dealloc(self);
		return NULL;
	}
	return self;
}

NSString *PXPalette_name(PXPalette *self)
{
	return self->name;
}

void PXPalette_setName(PXPalette *self, NSString *name)
{
	self->name = [name retain];
}

void PXPalette_addColorPair(PXPalette *self, PXPaletteColorPair pair)
{
	if(!self) {
		return;
	}
	NSColor *colorToAdd = _PXPalette_correctColor(pair.color);
	if(!colorToAdd) { return; }
  pair.color = [colorToAdd retain];
	if (self->size - self->colorCount <= 0) {
		if (self->size < 64) {
			PXPalette_resize(self, 64);
		} else {
			PXPalette_resize(self, self->size * 2);
		}
	}
	self->colors[self->colorCount] = pair;
	PXPalette_insertColorBucket(self, PXColorBucket_init(PXColorBucket_alloc(), colorToAdd, self->colorCount));
	self->colorCount++;
}

void PXPalette_addColor(PXPalette *self, NSColor *color)
{
  PXPalette_addColorPair(self, (PXPaletteColorPair){color, 1});
}

void PXPalette_resize(PXPalette *self, NSUInteger newSize)
{
	NSUInteger i;
	
	if (self->size == newSize) {
		return;
	}
	
	PXPaletteColorPair *oldColors = self->colors;
	if (newSize > 0) {
		self->colors = (PXPaletteColorPair *)calloc(newSize, sizeof(PXPaletteColorPair));
	} else {
		self->colors = NULL;
	}
	
	for (i=0; i<self->size; i++) {
		if (i < newSize) {
			self->colors[i] = oldColors[i];
		} else if (i < self->colorCount) {
			if (oldColors == NULL) {
				i = self->colorCount;
			} else {
				PXPalette_removeBucketForColor(self, oldColors[i].color);
				[oldColors[i].color release];
			}
		}
	}
	
	if (self->size > 0) {
		free(oldColors);
	}
	self->size = newSize;
	if (self->colorCount > self->size) {
		self->colorCount = self->size;
	}
}

NSColor *PXPalette_colorAtIndex(PXPalette *self, NSUInteger index) {
	if(index > self->colorCount) { return nil; }
	return self->colors[index].color;
}
