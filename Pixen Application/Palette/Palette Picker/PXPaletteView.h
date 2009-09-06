/* PXPaletteView */

#import <Cocoa/Cocoa.h>
#import "PXPalette.h"

@class PXColorPickerColorWellCell, PXCanvasDocument;
@interface PXPaletteView : NSView
{
	PXPalette *palette;
	PXColorPickerColorWellCell *colorCell;

	int floatingIndex, insertionIndex, previousFloatingIndex, finalIndex;
	PXCanvasDocument *document;
	NSMutableArray *paletteIndices;

	int rows, columns;
	int selectedIndex;
	float width, height;
	BOOL isEditable;
	BOOL outside;
	BOOL enabled;
	BOOL showsNewSwatch;
	NSControlSize controlSize;
	IBOutlet id delegate;
	
	BOOL newSwatchTinted;
}
- (void)setEnabled:(BOOL)enabled;
- (void)setDelegate:del;
- (id)initWithFrame:(NSRect)frameRect;
- (void)resizeWithOldSuperviewSize:(NSSize)size;
- (BOOL)isFlipped;
- (void)retile;
- (void)setDocument:doc;
- (PXPalette *)palette;
- (void)setPalette:(PXPalette *)pal;
- (void)drawRect:(NSRect)rect;
- (void)floatIndex:(int)index;
- (void)mouseDown:event;
- (void)mouseDragged:event;
- (void)mouseUp:event;
- (void)setEditable:(BOOL)ed;
- (int)indexOfCelAtPoint:(NSPoint)point;
- (void)setSelectedIndex:(int)index;
- (void)setControlSize:(NSControlSize)size;
- (NSControlSize)controlSize;

@end

@interface NSObject(PXPaletteViewDelegate)
- (void)useColorAtIndex:(unsigned)index event:(NSEvent *)e;
- (void)modifyColorAtIndex:(unsigned)index;
- (void)paletteViewSizeChangedTo:(NSControlSize)size;
@end
