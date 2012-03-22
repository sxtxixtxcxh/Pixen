//
//  PXPaletteView.h
//  Pixen
//
//  Copyright 2011-2012 Pixen. All rights reserved.
//

#import "PXPalette.h"

@interface PXPaletteView : NSView
{
  @private
	PXPalette *palette;
	
	int rows, columns;
	NSUInteger selectionIndex;
	CGFloat width;
	BOOL allowsColorSelection, allowsColorModification;
	NSControlSize controlSize;
	IBOutlet id delegate;
	
	NSMutableSet *_visibleLayers;
	NSMutableSet *_recycledLayers;
}

@property (nonatomic, assign) BOOL allowsColorSelection;
@property (nonatomic, assign) BOOL allowsColorModification;
@property (nonatomic, assign) NSControlSize controlSize;

@property (nonatomic, assign) NSUInteger selectionIndex;

@property (nonatomic, retain) PXPalette *palette;

@property (nonatomic, assign) id delegate;

- (void)reload;

@end


@interface NSObject (PXPaletteViewDelegate)

- (void)useColorAtIndex:(NSUInteger)index;
- (void)paletteView:(PXPaletteView *)pv modifyColorAtIndex:(NSUInteger)index;
- (void)paletteViewSizeChangedTo:(NSControlSize)size;

@end
