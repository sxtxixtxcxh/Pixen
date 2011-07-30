//
//  PXPreviewController.m
//  Pixen
//

#import <AppKit/AppKit.h>

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

- (BOOL)hasUsableCanvas;
- (id) init;
+ (id) sharedPreviewController;
- (void)windowWillClose:(NSNotification *) notification;
- (void)documentClosed:(NSNotification *)notification;
- (void)mouseEntered:(NSEvent *)event;
- (void)mouseExited:(NSEvent *)event;
- (void)dealloc;
- (void)shouldRedraw:timer;
- (void)updateTrackingRectAssumingInside:(BOOL)inside;
- (void)windowDidLoad;
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
- (IBAction)showWindow:(id) sender;
- (void)setCanvas:(PXCanvas *) aCanvas;
- (void)canvasDidChange:(NSNotification *)aNotification;
- (void)sizeToActual:sender;
- (void)sizeTo:sender;
- (void)prompter:(PXPreviewResizePrompter *)prompter didFinishWithZoomFactor:(float)factor;
@end
