//
//  PXScaleController.h
//  Pixen
//

#import <AppKit/AppKit.h>

@class PXCanvasWindowController, PXCanvas;

@interface PXScaleController : NSWindowController 
{
  @private
	IBOutlet NSPopUpButton *algorithmButton;
	// currently unused: IBOutlet NSBox *scaleParameterView;
	
	IBOutlet NSButton *scaleProportionallyCheckbox;
	IBOutlet NSTextField *pixelsWideField, *pixelsHighField, *percentageWideField, *percentageHighField;
	IBOutlet NSTextView *algorithmInfoView;
	
	
	id delegate;
	SEL callback;
	
	NSSize newSize;
	
	PXCanvasWindowController *canvasController;
}

- (void)scaleCanvasFromController:(PXCanvasWindowController *)canvasController
				   modalForWindow:(NSWindow *)theWindow;

- (IBAction)setAlgorithm:(id) sender;
- (IBAction)updateToScalePropotionally:(id) sender;
- (IBAction)synchronizeForms:(id) sender;
- (IBAction)cancel:(id) sender;
- (IBAction)scale:(id) sender;
- (void)scaleCanvas:(PXCanvas *)canvas;
- (void)setDelegate:delegate withCallback:(SEL)callback;
- pixelsWideField;
- pixelsHighField;
- percentageWideField;
- percentageHighField;

@end
