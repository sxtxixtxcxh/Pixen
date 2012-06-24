//
//  PXPreviewController.m
//  Pixen
//

@class PXAnimation, PXCanvas, PXCanvasPreviewView, PXPreviewBezelView, PXPreviewControlView, PXBackgroundController, PXPreviewResizePrompter;

@interface PXPreviewController : NSWindowController
{
  @private
	PXCanvasPreviewView *view;
	PXPreviewControlView *controlView;
	NSButton *playPauseButton;
	
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

@property (nonatomic, assign) IBOutlet PXCanvasPreviewView *view;
@property (nonatomic, assign) IBOutlet PXPreviewControlView *controlView;
@property (nonatomic, assign) IBOutlet NSButton *playPauseButton;

@property (nonatomic, assign) PXAnimation *animation;
@property (nonatomic, assign) PXCanvas *singleCanvas;

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
- (void)canvasDidChange:(NSNotification *)aNotification;
- (void)sizeToSenderTitlePercent:(id)sender;
- (void)sizeTo:sender;
- (void)prompter:(PXPreviewResizePrompter *)prompter didFinishWithZoomFactor:(float)factor;

@end
