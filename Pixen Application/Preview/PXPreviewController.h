//
//  PXPreviewController.m
//  Pixen
//

@class PXAnimation, PXCanvas, PXCanvasPreviewView, PXPreviewBezelView, PXPreviewControlView, PXBackgroundController, PXPreviewResizePrompter;

@interface PXPreviewController : NSWindowController < NSWindowRestoration >
{
  @private
	NSRect updateRect;
	NSWindow *resizeSizeWindow;
	PXPreviewBezelView *bezelView;
	NSTrackingRectTag trackingTag;
	
	NSTimer *_animationTimer;
	NSUInteger _currentAnimationCelIndex;
	
	BOOL liveResizing;
	NSSize sizingFactor;
	
	PXBackgroundController *backgroundController;
}

@property (nonatomic, weak) IBOutlet PXCanvasPreviewView *view;
@property (nonatomic, weak) IBOutlet PXPreviewControlView *controlView;
@property (nonatomic, weak) IBOutlet NSButton *playPauseButton;

@property (nonatomic, weak) PXAnimation *animation;
@property (nonatomic, weak) PXCanvas *singleCanvas;

+ (PXPreviewController *)sharedPreviewController;

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
