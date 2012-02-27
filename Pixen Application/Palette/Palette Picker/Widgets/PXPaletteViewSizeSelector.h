//
//  PXPaletteViewSizeSelector.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXPaletteViewSizeSelector : NSView
{
  @private
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
