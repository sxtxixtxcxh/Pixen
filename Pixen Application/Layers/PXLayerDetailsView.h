//
//  PXLayerDetailsView.h
//  Pixen
//

#import <Cocoa/Cocoa.h>

@class PXNSImageView, PXLayerTextField, PXLayerController, PXLayer;
@interface PXLayerDetailsView : NSView 
{
  @private
	IBOutlet PXLayerTextField *name;
	IBOutlet PXNSImageView *thumbnail;
	IBOutlet NSSlider *opacity;
	IBOutlet NSTextField *opacityText;
	IBOutlet NSView *view;
	IBOutlet NSButton *visibility;

	PXLayerController *layerController;
	
	PXLayer *layer;
	BOOL isHidden; //for backwards compatibility with 10.2
	NSRect changedRect;	
	BOOL selected;
}
@property (nonatomic, readwrite, assign) BOOL selected;
- (void)setLayerController:cont;
- (PXLayer *)layer;
- (void)focusOnName;
- (PXLayerTextField *)opacityText;
- (NSTextField *)name;
- (id) initWithLayer:(PXLayer *) aLayer;

- (void)setLayer:(PXLayer *)aLayer;

- (void)updatePreview:(NSNotification *) notification;

- (IBAction)opacityDidChange:(id) sender;
- (IBAction)nameDidChange:(id) sender;
- (IBAction)visibilityDidChange:(id)sender;

- (BOOL)isHidden;
- (void)setHidden:(BOOL)shouldHide;
@end
