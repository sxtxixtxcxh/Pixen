//
//  PXPaletteView.h
//  Pixen
//
//  Copyright 2011 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXPalette.h"

@class PXDocument;

@interface PXPaletteView : NSView
{
  @private
	PXDocument *document;
	PXPalette *palette;
	NSMutableArray *paletteIndices;
	
	int rows, columns;
	NSUInteger selectionIndex;
	float width, height;
	BOOL enabled, highlightEnabled;
	NSControlSize controlSize;
	IBOutlet id delegate;
}

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL highlightEnabled;
@property (nonatomic, assign) NSControlSize controlSize;

@property (nonatomic, assign) PXDocument *document;
@property (nonatomic, assign) PXPalette *palette;

@property (nonatomic, assign) id delegate;

- (void)setupLayer;
- (void)setNeedsRetile;

- (NSUInteger)indexOfCelAtPoint:(NSPoint)point;
- (void)toggleHighlightOnLayerAtIndex:(NSUInteger)index;

@end


@interface NSObject (PXPaletteViewDelegate)

- (void)useColorAtIndex:(NSUInteger)index;
- (void)modifyColorAtIndex:(NSUInteger)index;
- (void)paletteViewSizeChangedTo:(NSControlSize)size;

@end
