//
//  PXLayerController.h
//  Pixen
//

#import "PXCanvas.h"

@class PXLayer, PXLayerCollectionView;

@interface PXLayerController : NSViewController < NSCollectionViewDelegate >
{
  @private
	NSArrayController *_layersArray;
	
	NSUInteger _layersCreated;
	BOOL _ignoreSelectionChange;
}

@property (nonatomic, weak) IBOutlet PXLayerCollectionView *layersView;
@property (nonatomic, weak) IBOutlet NSButton *removeButton;
@property (nonatomic, strong) IBOutlet NSArrayController *layersArray;

@property (nonatomic, weak) PXCanvas *canvas;

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
