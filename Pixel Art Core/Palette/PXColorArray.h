//
//  PXColorArray.h
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "PXColor.h"

typedef struct PXColorArray *PXColorArrayRef;

typedef void (^PXColorArrayEnumerationBlock)(PXColor);

PXColorArrayRef PXColorArrayCreate(void);

void PXColorArrayRetain(PXColorArrayRef self);
void PXColorArrayRelease(PXColorArrayRef self);

NSUInteger PXColorArrayCount(PXColorArrayRef self);

NSUInteger PXColorArrayIndexOfColor(PXColorArrayRef self, PXColor color);
PXColor PXColorArrayColorAtIndex(PXColorArrayRef self, NSUInteger index);

void PXColorArrayEnumerateWithBlock(PXColorArrayRef self, PXColorArrayEnumerationBlock block);

void PXColorArrayAppendColor(PXColorArrayRef self, PXColor color);
void PXColorArrayInsertColorAtIndex(PXColorArrayRef self, NSUInteger index, PXColor color);

void PXColorArrayRemoveColorAtIndex(PXColorArrayRef self, NSUInteger index);

void PXColorArrayMoveColor(PXColorArrayRef self, NSUInteger sourceIndex, NSUInteger targetIndex);

/* behavior is undefined if `index` is out-of-bounds */
NSUInteger PXColorArrayColorInfoAtIndex(PXColorArrayRef self, NSUInteger index);
void PXColorArraySetColorInfoAtIndex(PXColorArrayRef self, NSUInteger index, NSUInteger info);
