//
//  PXPalette.m
//  Pixen
//

#import <AppKit/AppKit.h>

typedef struct _PXColorBucket {
	NSColor *color;
	NSUInteger index;
	struct _PXColorBucket *next;
} PXColorBucket;

typedef struct _PXPaletteColorPair {
  NSColor *color;
  NSInteger frequency;
} PXPaletteColorPair;

typedef struct {
	NSUInteger retainCount;
	
	PXPaletteColorPair *colors;
  
	NSUInteger colorCount;
	NSUInteger size;
	PXColorBucket **reverseHashTable;
	NSString *name;
	
	BOOL isSystemPalette;
	BOOL canSave;
} PXPalette;

NSUInteger PXPalette_getSystemPalettes(PXPalette **pals, NSUInteger initialIndex);
NSUInteger PXPalette_getUserPalettes(PXPalette **pals, NSUInteger initialIndex);
BOOL PXPalette_isDocumentPalette(PXPalette *self);

PXPalette *PXPalette_alloc(void);

PXPalette *PXPalette_init(PXPalette *self);
PXPalette *PXPalette_initWithoutBackgroundColor(PXPalette *self);
PXPalette *PXPalette_initWithContentsOfFile(PXPalette *self, NSString *file);
PXPalette *PXPalette_initWithDictionary(PXPalette *self, NSDictionary *dict);
PXPalette *PXPalette_copy(PXPalette *self);
void PXPalette_dealloc(PXPalette *self);
PXPalette *PXPalette_retain(PXPalette *self);
PXPalette *PXPalette_release(PXPalette *self);

NSString *PXPalette_name(PXPalette *self);
void PXPalette_setName(PXPalette *self, NSString *name);

void PXPalette_resize(PXPalette *self, NSUInteger newSize);
void PXPalette_addColorPair(PXPalette *self, PXPaletteColorPair pair);
void PXPalette_addColor(PXPalette *self, NSColor *color);
void PXPalette_addBackgroundColor(PXPalette *self);
void PXPalette_addColorWithoutDuplicating(PXPalette *self, NSColor *color);
void PXPalette_removeColorAtIndex(PXPalette *self, NSUInteger index);
void PXPalette_insertColorAtIndex(PXPalette *self, NSColor *color, NSUInteger index);
PXColorBucket *PXPalette_bucketForColor(PXPalette *self, NSColor *color);

void PXPalette_swapColorsAtIndex(PXPalette* self, NSUInteger colorIndex1, NSUInteger colorIndex2);
void PXPalette_swapColors(PXPalette* self, NSColor *color1, NSColor *color2);
void PXPalette_cycleColors(PXPalette *self);
void PXPalette_setColorAtIndex(PXPalette *self, NSColor *color, NSUInteger index);
void PXPalette_moveColorAtIndexToIndex(PXPalette *self, NSUInteger index1, NSUInteger index2);

NSUInteger PXPalette_indexOfColor(PXPalette *self, NSColor *color);
NSColor *PXPalette_colorAtIndex(PXPalette *self, NSUInteger index);
NSUInteger PXPalette_indexOfColorAddingIfNotPresent(PXPalette *self, NSColor *color);
NSUInteger PXPalette_indexOfColorClosestTo(PXPalette *self, NSColor *color);
NSColor *PXPalette_colorClosestTo(PXPalette *self, NSColor *color);
NSColor *PXPalette_restrictColor(PXPalette *self, NSColor *color);
void PXPalette_removeAlphaComponents(PXPalette *self);

PXPalette *PXPalette_initWithCoder(PXPalette *self, NSCoder *coder);
void PXPalette_encodeWithCoder(PXPalette *self, NSCoder *coder);
NSDictionary *PXPalette_dictForArchiving(PXPalette *self);

double PXPalette_hashEfficiency(PXPalette *self);

NSUInteger PXPalette_colorCount(PXPalette *self);
NSArray *PXPalette_colors(PXPalette *self);

void PXPalette_decrementColorCount(PXPalette *self, NSColor *color, NSInteger amt);
void PXPalette_incrementColorCount(PXPalette *self, NSColor *color, NSInteger amt);
