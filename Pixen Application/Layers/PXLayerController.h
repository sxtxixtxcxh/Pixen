//
//  PXLayerController.h
//  Pixen
//

#import <AppKit/AppKit.h>
#import "PXCanvas.h"

@class PXLayer, PXLayerCollectionView, PXCanvas, PXDocument;

@interface PXLayerController : NSViewController < NSCollectionViewDelegate >
{
  @private
	IBOutlet PXLayerCollectionView *layersView;
	IBOutlet NSButton *removeButton;
	IBOutlet NSArrayController *layersArray;
	NSView *subview;
	
	PXCanvas *canvas;
	PXDocument *document;
	NSUInteger layersCreated;
	
	// for programmatic expand/collapse
	CGFloat lastSubviewHeight;
}

@property (nonatomic, assign) PXDocument *document;
@property (nonatomic, retain) PXCanvas *canvas;

- (id)initWithCanvas:(PXCanvas *)aCanvas;

- (void)setSubview:(NSView *)sv;

- (void)selectNextLayer;
- (void)selectPreviousLayer;

- (IBAction)addLayer:(id)sender;

- (IBAction)removeLayer:(id)sender;
- (void)removeLayerObject:(PXLayer *)layer;

- (void)selectRow:(NSUInteger)index;

- (void)cutSelectedLayer;
- (void)cutLayerObject:(PXLayer *)layer;

- (void)duplicateSelectedLayer;
- (void)duplicateLayerObject:(PXLayer *)layer;

- (void)mergeDownSelectedLayer;
- (void)mergeDownLayerObject:(PXLayer *)layer;

@end
