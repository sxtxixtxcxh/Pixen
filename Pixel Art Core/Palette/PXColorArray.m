//
//  PXColorArray.m
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "PXColorArray.h"

#define COLOR_BATCH_SIZE 1024

struct PXColorArray {
	PXColor *_colors;
	NSUInteger _count;
	NSUInteger _allocatedCount;
	
	NSUInteger _retainCount;
};

static void PXColorArrayReallocByOne(PXColorArrayRef self);

PXColorArrayRef PXColorArrayCreate(void)
{
	PXColorArrayRef array = malloc(sizeof(struct PXColorArray));
	array->_colors = NULL;
	array->_count = array->_allocatedCount = 0;
	array->_retainCount = 1;
	
	return array;
}

static void PXColorArrayReallocByOne(PXColorArrayRef self)
{
	if (!self->_colors) {
		self->_colors = malloc(sizeof(PXColor) * COLOR_BATCH_SIZE);
		self->_allocatedCount = COLOR_BATCH_SIZE;
	}
	
	if (self->_count+1 > self->_allocatedCount) {
		NSUInteger nac = self->_allocatedCount + COLOR_BATCH_SIZE;
		
		self->_colors = realloc(self->_colors, sizeof(PXColor) * nac);
		self->_allocatedCount = nac;
	}
}

void PXColorArrayRetain(PXColorArrayRef self)
{
	if (self == NULL)
		return;
	
	self->_retainCount++;
}

void PXColorArrayRelease(PXColorArrayRef self)
{
	if (self == NULL)
		return;
	
	self->_retainCount--;
	
	if (!self->_retainCount) {
		if (self->_colors)
			free(self->_colors);
		
		free(self);
	}
}

NSUInteger PXColorArrayCount(PXColorArrayRef self)
{
	return self->_count;
}

NSUInteger PXColorArrayIndexOfColor(PXColorArrayRef self, PXColor color)
{
	for (NSUInteger i = 0; i < self->_count; i++) {
		if (PXColorEqualsColor(self->_colors[i], color))
			return i;
	}
	
	return NSNotFound;
}

PXColor PXColorArrayColorAtIndex(PXColorArrayRef self, NSUInteger index)
{
	NSCAssert(index < self->_count, @"Out-of-bounds index");
	
	return self->_colors[index];
}

void PXColorArraySetColorAtIndex(PXColorArrayRef self, NSUInteger index, PXColor color)
{
	NSCAssert(index < self->_count, @"Out-of-bounds index");
	
	self->_colors[index] = color;
}

void PXColorArrayEnumerateWithBlock(PXColorArrayRef self, PXColorArrayEnumerationBlock block)
{
	for (NSUInteger i = 0; i < self->_count; i++) {
		block(self->_colors[i]);
	}
}

void PXColorArrayAppendColor(PXColorArrayRef self, PXColor color)
{
	PXColorArrayReallocByOne(self);
	
	self->_colors[self->_count] = color;
	self->_count++;
}

void PXColorArrayInsertColorAtIndex(PXColorArrayRef self, NSUInteger index, PXColor color)
{
	NSCAssert(index <= self->_count, @"Out-of-bounds index");
	
	PXColorArrayReallocByOne(self);
	
	if (self->_count) {
		for (NSUInteger n = self->_count; n > index; n--) {
			self->_colors[n] = self->_colors[n-1];
		}
	}
	
	self->_colors[index] = color;
	self->_count++;
}

void PXColorArrayRemoveColorAtIndex(PXColorArrayRef self, NSUInteger index)
{
	NSCAssert(index < self->_count, @"Out-of-bounds index");
	
	for (NSUInteger n = index; n < self->_count-1; n++) {
		self->_colors[n] = self->_colors[n+1];
	}
	
	self->_count--;
	
	bzero(self->_colors+self->_count, sizeof(PXColor));
}

void PXColorArrayMoveColor(PXColorArrayRef self, NSUInteger sourceIndex, NSUInteger targetIndex)
{
	NSCAssert(sourceIndex < self->_count, @"Out-of-bounds source index");
	
	if (targetIndex != sourceIndex) {
		PXColor sourceColor = PXColorArrayColorAtIndex(self, sourceIndex);
		PXColorArrayRemoveColorAtIndex(self, sourceIndex);
		
		if (targetIndex >= self->_count) {
			PXColorArrayAppendColor(self, sourceColor);
		}
		else {
			PXColorArrayInsertColorAtIndex(self, targetIndex, sourceColor);
		}
	}
}

void PXColorArraySort(PXColorArrayRef self, PXColorComparator block)
{
	qsort_b(self->_colors, self->_count, sizeof(PXColor), ^int(const void *a, const void *b) {
		return block((PXColor *)a, (PXColor *)b);
	});
}

NSUInteger PXColorArrayColorInfoAtIndex(PXColorArrayRef self, NSUInteger index)
{
	return self->_colors[index].info;
}

void PXColorArraySetColorInfoAtIndex(PXColorArrayRef self, NSUInteger index, NSUInteger info)
{
	self->_colors[index].info = info;
}
