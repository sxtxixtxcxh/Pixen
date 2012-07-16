//
//  PXScaleController.h
//  Pixen
//

@class PXCanvasWindowController, PXCanvas;
@protocol PXScaleControllerDelegate;

@interface PXScaleController : NSWindowController 
{
  @private
	NSSize newSize;
	PXCanvasWindowController *canvasController;
}

@property (nonatomic, weak) IBOutlet NSPopUpButton *algorithmButton;

@property (nonatomic, weak) IBOutlet NSButton *scaleProportionallyCheckbox;
@property (nonatomic, weak) IBOutlet NSTextField *pixelsWideField, *pixelsHighField, *percentageWideField, *percentageHighField;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *algorithmInfoView;

@property (nonatomic, weak) id < PXScaleControllerDelegate > delegate;

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
