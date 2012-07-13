//
//  PXImageBackground.h
//  Pixen
//

#import "PXColor.h"
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

PXColor PXImage_colorAtIndex(PXImage *self, unsigned index);
PXColor PXImage_colorAtXY(PXImage *self, int x, int y);

void PXImage_setColorAtXY(PXImage *self, PXColor color, int x, int y);
void PXImage_setColorAtIndex(PXImage *self, PXColor color, unsigned index);

void PXImage_replaceColorWithColor(PXImage *self, PXColor srcColor, PXColor destColor);

NSData *PXImage_colorData(PXImage *self);
void PXImage_setColorData(PXImage *self, NSData *data);

void PXImage_clear(PXImage *self, PXColor color);

void PXImage_flipHorizontally(PXImage *self);
void PXImage_flipVertically(PXImage *self);
void PXImage_translate(PXImage *self, int deltaX, int deltaY, BOOL wrap);
void PXImage_rotateByDegrees(PXImage *self, int degrees);

void PXImage_setSize(PXImage *self, NSSize newSize, NSPoint origin, PXColor backgroundColor);

void PXImage_drawInRectFromRectWithOperationFraction(PXImage *self, NSRect dst, NSRect src, NSCompositingOperation operation, double opacity);
void PXImage_compositeUnder(PXImage *self, PXImage *other, BOOL blend);
void PXImage_compositeUnderInRect(PXImage *self, PXImage *other, NSRect aRect, BOOL blend);

NSData *PXImage_encodedData(PXImage *self);
PXImage *PXImage_initWithData(PXImage *self, NSData *data);

//`legacyPalette` is passed for 3.2 compatibility. It may be NULL.
PXImage *PXImage_initWithCoder(PXImage *self, NSCoder *coder, PXPalette *legacyPalette);
void PXImage_encodeWithCoder(PXImage *self, NSCoder *coder);

NSBitmapImageRep *PXImage_imageRep(PXImage *self);
