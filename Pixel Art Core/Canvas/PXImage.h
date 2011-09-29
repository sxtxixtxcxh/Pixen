//
//  PXImageBackground.h
//  Pixen
//

#import <AppKit/AppKit.h>
#import "PXPalette.h"

typedef struct {
	CGContextRef painting; //we draw into its bytes and make an image out of it when it changes
	CGImageRef image; //we draw it onto the context during drawrect
	CGPoint location;
} PXTile;

typedef struct {
	PXTile** tiles;
	unsigned tileCount;
	CGColorSpaceRef colorspace;	

	int retainCount;
		
	int width, height;
} PXImage;

PXImage *PXImage_alloc();

PXImage *PXImage_init(PXImage *self);
PXImage *PXImage_initWithSize(PXImage *self, NSSize size);
void PXImage_dealloc(PXImage *self);
PXImage *PXImage_copy(PXImage *self);
PXImage *PXImage_retain(PXImage *self);
PXImage *PXImage_release(PXImage *self);

NSColor *PXImage_backgroundColor(PXImage *self);

NSColor *PXImage_colorAtIndex(PXImage *self, int loc);
NSColor *PXImage_colorAtXY(PXImage *self, int x, int y);
void PXImage_setColorAtXY(PXImage *self, NSColor *color, int x, int y);
void PXImage_setColorAtIndex(PXImage *self, NSColor *c, unsigned loc);
void PXImage_clear(PXImage *self, NSColor *c);

void PXImage_flipHorizontally(PXImage *self);
void PXImage_flipVertically(PXImage *self);
void PXImage_translate(PXImage *self, int deltaX, int deltaY, BOOL wrap);
void PXImage_rotateByDegrees(PXImage *self, int degrees);

void PXImage_setSize(PXImage *self, NSSize newSize, NSPoint origin, NSColor * backgroundColor);

void PXImage_drawInRectFromRectWithOperationFraction(PXImage *self, NSRect dst, NSRect src, NSCompositingOperation operation, double opacity);
void PXImage_compositeUnder(PXImage *self, PXImage *other, BOOL blend);
void PXImage_compositeUnderInRect(PXImage *self, PXImage *other, NSRect aRect, BOOL blend);

NSColor * PXImage_blendColors(PXImage * self, NSColor * bottomColor, NSColor * topColor);

NSData *PXImage_encodedData(PXImage *self);
PXImage *PXImage_initWithData(PXImage *self, NSData *data);

//`legacyPalette` is passed for 3.2 compatibility. It may be NULL.
PXImage *PXImage_initWithCoder(PXImage *self, NSCoder *coder, PXPalette *legacyPalette);
void PXImage_encodeWithCoder(PXImage *self, NSCoder *coder);

NSImage *PXImage_NSImage(PXImage *self);
NSImage *PXImage_bitmapImage(PXImage *self);
