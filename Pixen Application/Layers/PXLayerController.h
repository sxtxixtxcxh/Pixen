//
//  PXLayerController.h
//  Pixen
//

#import "PXCanvas.h"

@interface PXLayerController : NSViewController < NSTableViewDataSource, NSTableViewDelegate >
{
  @private
	NSUInteger _layersCreated;
	BOOL _ignoreSelectionChange;
}

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSButton *removeButton;

@property (nonatomic, weak) PXCanvas *canvas;

- (id)initWithCanvas:(PXCanvas *)aCanvas;

- (void)selectNextLayer;
- (void)selectPreviousLayer;

- (IBAction)addLayer:(id)sender;

- (IBAction)removeLayer:(id)sender;

- (void)selectLayerAtIndex:(NSUInteger)index;

- (void)promoteSelection;

- (void)copySelectedLayer;
- (void)cutSelectedLayer;
- (void)pasteLayer;

- (void)duplicateSelectedLayer;

- (void)mergeDownSelectedLayer;

@end
