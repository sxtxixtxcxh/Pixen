//
//  PXPreviewController.m
//  Pixen
//

@class PXCanvas, PXCanvasPreviewView, PXPreviewBezelView, PXBackgroundController, PXPreviewResizePrompter;

@interface PXPreviewController : NSWindowController
{
  @private
	IBOutlet PXCanvasPreviewView *view;
	PXCanvas *canvas;
	NSRect updateRect;
	NSWindow *resizeSizeWindow;
	PXPreviewBezelView *bezelView;
	NSTrackingRectTag trackingTag;
	
	BOOL liveResizing;
	NSSize sizingFactor;
	
	PXBackgroundController *backgroundController;
}

+ (id)sharedPreviewController;

- (BOOL)hasUsableCanvas;
- (void)documentClosed:(NSNotification *)notification;
- (void)shouldRedraw:timer;
- (void)updateTrackingRectAssumingInside:(BOOL)inside;
- (void)updateViewPercentage;
- (NSSize)properWindowSizeForCanvasSize:(NSSize)size;
- (void)liveResize;
- (void)sizeToCanvas;
- (void)setCanvasSize:(NSSize)size;
- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize;
- (void)updateResizeSizeViewScale;
- (void)centerContent;
- (void)windowDidResize:(NSNotification *)aNotification;
- (void)initializeWindow;
- (void)setCanvas:(PXCanvas *) aCanvas;
- (void)canvasDidChange:(NSNotification *)aNotification;
- (void)sizeToActual:sender;
- (void)sizeTo:sender;
- (void)prompter:(PXPreviewResizePrompter *)prompter didFinishWithZoomFactor:(float)factor;

@end
