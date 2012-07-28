//
//  PXPaletteView.h
//  Pixen
//
//  Copyright 2011-2012 Pixen. All rights reserved.
//

#import "PXPalette.h"

@class PXInsertionView;

@interface PXPaletteView : NSView
{
  @private
	PXPalette *palette;
	
	int rows, columns;
	NSUInteger selectionIndex;
	CGFloat width;
	BOOL allowsColorSelection, allowsColorModification;
	NSControlSize controlSize;
	
	NSMutableSet *_visibleViews;
	NSMutableSet *_recycledViews;
	
	NSUInteger _clickedCelIndex;
	BOOL _dragging;
	PXInsertionView *_insertionView;
}

@property (nonatomic, assign) BOOL allowsColorSelection;
@property (nonatomic, assign) BOOL allowsColorModification;
@property (nonatomic, assign) NSControlSize controlSize;

@property (nonatomic, assign, readonly) NSUInteger selectionIndex;

@property (nonatomic, strong) PXPalette *palette;

@property (nonatomic, unsafe_unretained) id delegate;

- (void)reload;

- (void)selectColorAtIndex:(NSUInteger)index;

@end


@interface NSObject (PXPaletteViewDelegate)

- (void)useColorAtIndex:(NSUInteger)index;
- (void)paletteView:(PXPaletteView *)pv modifyColorAtIndex:(NSUInteger)index;
- (void)paletteViewSizeChangedTo:(NSControlSize)size;

@end
