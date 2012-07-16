//
//  PXToolPaletteController.h
//  Pixen
//

@class PXToolSwitcher, PXCanvasController;

@interface PXToolPaletteRightToolGradientView : NSImageView { }
@end

@interface PXToolPaletteController: NSWindowController
{
  @private
	BOOL _locked;
	BOOL usingRightToolBeforeLock;
	BOOL controlKeyDown;
	BOOL rightMouseDown;
	unsigned int keyMask;
	
	NSRect _lastFrameFS;
}

@property (nonatomic, strong) IBOutlet PXToolSwitcher *leftSwitcher;
@property (nonatomic, strong) IBOutlet PXToolSwitcher *rightSwitcher;
@property (nonatomic, weak) IBOutlet id minimalView;
@property (nonatomic, weak) IBOutlet NSBox *rightSwitchView;
@property (nonatomic, weak) IBOutlet NSButton *triangle;
@property (nonatomic, weak) IBOutlet NSImageView *rightToolGradient;

+ (PXToolPaletteController *)sharedToolPaletteController;

- (void)enterFullScreenWithDuration:(NSTimeInterval)duration;
- (void)exitFullScreenWithDuration:(NSTimeInterval)duration;

- (void)clearBeziers;

	//Action method
- (IBAction)disclosureClicked:(id)sender;

	//Events methods
- (void)keyDown:(NSEvent *)event fromCanvasController:(PXCanvasController *)cc;
- (BOOL)keyWasDown:(NSUInteger)mask;
- (BOOL)isMask:(NSUInteger)newMask upEventForModifierMask:(unsigned int)mask;
- (BOOL)isMask:(NSUInteger)newMask downEventForModifierMask:(unsigned int)mask;

- (void)rightMouseDown;
- (void)rightMouseUp;
- (BOOL)usingRightTool;

	//Accessor methods
- (id)leftTool;
- (id)rightTool;
- (id)currentTool;
- (PXToolSwitcher *)leftSwitcher;
- (PXToolSwitcher *)rightSwitcher;
- (NSPanel *)toolPanel;

@end
