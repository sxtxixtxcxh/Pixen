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
	float width, height;
	BOOL enabled;
	NSControlSize controlSize;
	IBOutlet id delegate;
}

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) NSControlSize controlSize;

@property (nonatomic, assign) PXDocument *document;
@property (nonatomic, assign) PXPalette *palette;

@property (nonatomic, assign) id delegate;

- (void)setupLayer;
- (void)setNeedsRetile;

- (int)indexOfCelAtPoint:(NSPoint)point;

@end


@interface NSObject (PXPaletteViewDelegate)

- (void)useColorAtIndex:(unsigned)index event:(NSEvent *)event;
- (void)modifyColorAtIndex:(unsigned)index;
- (void)paletteViewSizeChangedTo:(NSControlSize)size;

@end
