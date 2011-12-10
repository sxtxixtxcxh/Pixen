//
//  PXPaletteViewScrollView.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

@class PXPaletteViewSizeSelector;

@interface PXPaletteViewScrollView : NSScrollView
{
	PXPaletteViewSizeSelector *_sizeSelector;
    NSControlSize _controlSize;
}

@property (nonatomic, assign) NSControlSize controlSize;

@end
