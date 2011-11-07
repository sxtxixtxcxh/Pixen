//
//  PXScaleAlgorithm.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@class PXCanvas;

@interface PXScaleAlgorithm : NSObject

+ (id)algorithm;

- (NSString *)name;
- (NSString *)nibName;
- (NSString *)algorithmInfo;

- (BOOL)canScaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size;
- (void)scaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size;

@end
