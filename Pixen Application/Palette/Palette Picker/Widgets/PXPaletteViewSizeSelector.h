//
//  PXPaletteViewSizeSelector.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@interface PXPaletteViewSizeSelector : NSView
{
	NSImage *_bigImage;
    NSImage *_smallImage;
    NSControlSize _controlSize;
    id _delegate;
}

@property (nonatomic, assign) NSControlSize controlSize;
@property (nonatomic, assign) id delegate;

@end

@interface NSObject (PXPaletteViewSizeSelectorDelegateProtocol)

- (void)sizeSelector:(PXPaletteViewSizeSelector *)selector selectedSize:(NSControlSize)size;

@end
