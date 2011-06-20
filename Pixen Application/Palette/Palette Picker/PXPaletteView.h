/* PXPaletteView */

#import <Cocoa/Cocoa.h>
#import "PXPalette.h"

@class PXColorPickerColorWellCell, PXCanvasDocument;
@interface PXPaletteView : NSView
{
  @private
	PXPalette *palette;
	PXColorPickerColorWellCell *colorCell;

	PXCanvasDocument *document;
	NSMutableArray *paletteIndices;

	int rows, columns;
	float width, height;
	BOOL enabled;
	NSControlSize controlSize;
	IBOutlet id delegate;
}

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) id delegate;

- (id)initWithFrame:(NSRect)frameRect;
- (void)resizeWithOldSuperviewSize:(NSSize)size;
- (BOOL)isFlipped;
- (void)retile;
- (void)setDocument:doc;
- (PXPalette *)palette;
- (void)setPalette:(PXPalette *)pal;
- (void)drawRect:(NSRect)rect;
- (void)mouseDown:event;
- (void)mouseDragged:event;
- (void)mouseUp:event;
- (int)indexOfCelAtPoint:(NSPoint)point;
- (void)setControlSize:(NSControlSize)size;
- (NSControlSize)controlSize;

@end

@interface NSObject(PXPaletteViewDelegate)
- (void)useColorAtIndex:(unsigned)index event:(NSEvent *)e;
//- (void)modifyColorAtIndex:(unsigned)index;
- (void)paletteViewSizeChangedTo:(NSControlSize)size;
@end
