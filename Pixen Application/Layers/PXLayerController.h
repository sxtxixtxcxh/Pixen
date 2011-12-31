//
//  PXLayerController.h
//  Pixen
//

#import "PXCanvas.h"

@class PXLayer, PXLayerCollectionView;

@interface PXLayerController : NSViewController < NSCollectionViewDelegate >
{
  @private
	PXLayerCollectionView *_layersView;
	NSButton *_removeButton;
	NSArrayController *_layersArray;
	
	PXCanvas *_canvas;
	NSUInteger _layersCreated;
	BOOL _ignoreSelectionChange;
}

@property (nonatomic, assign) IBOutlet PXLayerCollectionView *layersView;
@property (nonatomic, assign) IBOutlet NSButton *removeButton;
@property (nonatomic, retain) IBOutlet NSArrayController *layersArray;

@property (nonatomic, assign) PXCanvas *canvas;

- (id)initWithCanvas:(PXCanvas *)aCanvas;

- (void)selectNextLayer;
- (void)selectPreviousLayer;

- (IBAction)addLayer:(id)sender;

- (IBAction)removeLayer:(id)sender;
- (void)removeLayerObject:(PXLayer *)layer;

- (void)selectLayerAtIndex:(NSUInteger)index;

- (void)promoteSelection;

- (void)copySelectedLayer;
- (void)copyLayerObject:(PXLayer *)layer;

- (void)cutSelectedLayer;
- (void)cutLayerObject:(PXLayer *)layer;

- (void)pasteLayer;

- (void)duplicateSelectedLayer;
- (void)duplicateLayerObject:(PXLayer *)layer;

- (void)mergeDownSelectedLayer;
- (void)mergeDownLayerObject:(PXLayer *)layer;

@end
