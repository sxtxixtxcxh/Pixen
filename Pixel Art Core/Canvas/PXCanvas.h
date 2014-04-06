//
//  PXCanvas.h
//  Pixen
//

#import "PXColorArray.h"
#import "PXGrid.h"
#import "PXLayer.h"
#import "PXPalette.h"

typedef BOOL *PXSelectionMask;

@class PXBackground, PXBackgroundConfig;

@interface PXCanvas : NSObject < NSCopying >
{
  @private
	NSMutableArray *layers;
	
	//I want to move these to the document somehow, eventually.
	//Maybe for Pixen 5... but it would require a huge overhaul
	//of mostly everything to allow for moving around responsibilities
	//at this point.  is it worth it?  yeah, probably.  but do I have time
	//for it now?  well...  --joe
	PXLayer *__weak activeLayer;
	NSMutableArray *tempLayers;
	
	PXSelectionMask selectionMask;
	BOOL hasSelection;
	NSPoint selectionOrigin;
	
	NSRect canvasRect;  //Cached because [self size] and NSMakeRect slow things down when containsPoint is called a bunch
	NSRect selectedRect;
	NSUndoManager *__weak undoManager; // Cached from PXCanvasDocument
	NSPointerArray *_drawnPoints;
	PXColorArrayRef _oldColors, _newColors;
	
	//these are slightly easier to move, but will still suck to move.
	PXBackgroundConfig *bgConfig;
	PXGrid *grid;
	NSSize previewSize;
	
	BOOL frequencyPaletteDirty;
	NSCountedSet *_minusColors;
	NSCountedSet *_plusColors;
}

@property (nonatomic, strong) PXGrid *grid;

@property (nonatomic, strong, readonly) NSArray *tempLayers;

- (void)reallyRefreshWholePalette;
- (void)refreshWholePalette;
- (NSBitmapImageRep *)spriteSheetWithCelMargin:(int)margin;
- (NSUInteger)countOfLayers;
- (NSUInteger)countOfVisibleLayers;

- (void)beginColorUpdates;
- (void)endColorUpdates;

- (void)setUndoManager:(NSUndoManager *)manager;
- (NSUndoManager *)undoManager;

- (void)recacheSize;

- (NSSize)size;

- (void)setSize:(NSSize)newSize;
- (void)setSize:(NSSize)newSize withOrigin:(NSPoint)origin backgroundColor:(PXColor)color;

- (void)updatePreviewSize;

- (NSSize)previewSize;
- (void)setPreviewSize:(NSSize)size;

- (void)beginUndoGrouping;
- (void)endUndoGrouping;

- (PXColor)eraseColor;

+ (PXPalette *)frequencyPaletteForLayers:(NSArray *)layers;

@end
