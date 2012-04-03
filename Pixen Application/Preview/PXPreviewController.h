//
//  PXPreviewController.m
//  Pixen
//

@class PXAnimation, PXCanvas, PXCanvasPreviewView, PXPreviewBezelView, PXBackgroundController, PXPreviewResizePrompter;

@interface PXPreviewController : NSWindowController
{
  @private
	IBOutlet PXCanvasPreviewView *view;
	PXCanvas *canvas;
	NSRect updateRect;
	NSWindow *resizeSizeWindow;
	PXPreviewBezelView *bezelView;
	NSTrackingRectTag trackingTag;
	
	PXAnimation *_animation;
	NSTimer *_animationTimer;
	NSUInteger _currentAnimationCelIndex;
	
	BOOL liveResizing;
	NSSize sizingFactor;
	
	PXBackgroundController *backgroundController;
}

+ (id)sharedPreviewController;

- (void)setAnimation:(PXAnimation *)animation;
- (void)setSingleCanvas:(PXCanvas *)aCanvas;

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
- (void)canvasDidChange:(NSNotification *)aNotification;
- (void)sizeToSenderTitlePercent:(id)sender;
- (void)sizeTo:sender;
- (void)prompter:(PXPreviewResizePrompter *)prompter didFinishWithZoomFactor:(float)factor;

@end
