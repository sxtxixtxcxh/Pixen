//
//  PXLayerController.h
//  Pixen
//

#import <AppKit/AppKit.h>
#import "PXCanvas.h"

@class PXLayer, PXCanvas, PXDocument;
@interface PXLayerController : NSViewController <NSCollectionViewDelegate>
{
  @private
	IBOutlet NSCollectionView *layersView;
	PXCanvas *canvas;
	NSMutableArray *views;

	NSView *subview;
	IBOutlet NSButton *removeButton;
	PXDocument *document;
	int layersCreated;

	NSIndexSet *selection;
	
	//for programmatic expand/collapse
	CGFloat lastSubviewHeight;
}
-(id) initWithCanvas:(PXCanvas *)aCanvas;
- (void)setSubview:(NSView *)sv;
- (void)reloadData:(NSNotification *) aNotification;
- (void)setCanvas:(PXCanvas *) aCanvas;
- (PXCanvas *)canvas;
- (void)setDocument:(id)doc;

- (IBAction)addLayer: (id)sender;
- (IBAction)duplicateLayer: (id)sender;
- (void)duplicateLayerObject: (PXLayer *)layer;
- (IBAction)removeLayer: (id)sender;
- (void)removeLayerObject: (PXLayer *)layer;
- (IBAction)selectLayer: (id)sender;
- (void)selectRow:(NSUInteger)index;

- (IBAction)nextLayer: (id)sender;
- (IBAction)previousLayer: (id)sender;

- (void)mergeDown;

- (void)updateRemoveButtonStatus;

- (void)mergeDownLayerObject:(PXLayer *)layer;

- (NSUInteger)invertLayerIndex:(NSUInteger)anIndex;

- (void)deleteKeyPressedInCollectionView:(NSCollectionView *)cv;

@end
