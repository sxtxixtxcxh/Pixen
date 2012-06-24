//
//  PXScaleController.h
//  Pixen
//

@class PXCanvasWindowController, PXCanvas;
@protocol PXScaleControllerDelegate;

@interface PXScaleController : NSWindowController 
{
  @private
	IBOutlet NSPopUpButton *algorithmButton;
	// currently unused: IBOutlet NSBox *scaleParameterView;
	
	IBOutlet NSButton *scaleProportionallyCheckbox;
	IBOutlet NSTextField *pixelsWideField, *pixelsHighField, *percentageWideField, *percentageHighField;
	IBOutlet NSTextView *algorithmInfoView;
	
	id < PXScaleControllerDelegate > delegate;
	
	NSSize newSize;
	
	PXCanvasWindowController *canvasController;
}

@property (nonatomic, assign) id < PXScaleControllerDelegate > delegate;

- (void)scaleCanvasFromController:(PXCanvasWindowController *)canvasController
				   modalForWindow:(NSWindow *)theWindow;

- (IBAction)setAlgorithm:(id) sender;
- (IBAction)updateToScalePropotionally:(id) sender;
- (IBAction)synchronizeForms:(id) sender;
- (IBAction)cancel:(id) sender;
- (IBAction)scale:(id) sender;
- (void)scaleCanvas:(PXCanvas *)canvas;

@end


@protocol PXScaleControllerDelegate

- (void)scaleControllerDidFinish:(PXScaleController *)controller scale:(BOOL)scale;

@end
