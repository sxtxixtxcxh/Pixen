//
//  PXPaletteColorView.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXPaletteColorView : NSView

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSColor *color;
@property (nonatomic, assign) NSControlSize controlSize;
@property (nonatomic, assign) BOOL highlighted;

@end
