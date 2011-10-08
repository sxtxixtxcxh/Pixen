//
//  PXPaletteColorLayer.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@interface PXPaletteColorLayer : CALayer

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, retain) NSColor *color;
@property (nonatomic, assign) NSControlSize controlSize;
@property (nonatomic, assign) BOOL highlighted;

@end
