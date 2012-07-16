//
//  PXToolSwitcher.h
//  Pixen
//

@class PXTool, PXCanvasController;

typedef enum {
	PXPencilToolTag = 0,
	PXEraserToolTag,
	PXEyedropperToolTag,
	PXZoomToolTag,
	PXRectangularSelectionToolTag,
	PXMagicWandToolTag,
	PXLassoToolTag,
	PXMoveToolTag,
	PXFillToolTag,
	PXLineToolTag,
	PXRectangleToolTag,
	PXEllipseToolTag
} PXToolTag;


@interface PXToolSwitcher : NSObject
{
  @private
	NSMutableArray *tools;
	
	NSColor *_color;
	PXTool *__weak _tool;
	PXTool *__weak _lastTool;
	BOOL _locked;
	BOOL _showingTemporaryEyedropper;
}

@property (nonatomic, weak) IBOutlet NSMatrix *toolsMatrix;
@property (nonatomic, weak) IBOutlet NSColorWell *colorWell;

+ (NSArray *)toolClasses;

- (id)selectedTool;

- (id)toolWithTag:(PXToolTag)tag;
- (PXToolTag)tagForTool:(id)aTool;
- (void)setIcon:(NSImage *)anImage forTool:(id)aTool;
- (void)clearBeziers;

	//Manage color/colorWell
- (NSColor *)color;
- (void)setColor:(NSColor *)aColor;
- (void)activateColorWell;

- (void)lock;
- (void)unlock;

- (void)useTool:aTool;
- (void)useToolTagged:(PXToolTag)tag;

	//Actions methods
- (IBAction)toolClicked:(id)sender;
- (IBAction)colorChanged:(id)sender;

	//Events methods
- (void)keyDown:(NSEvent *)event fromCanvasController:(PXCanvasController *)cc;
- (void)optionKeyDown;
- (void)optionKeyUp;
- (void)shiftKeyDown;
- (void)shiftKeyUp;
- (void)commandKeyDown;
- (void)commandKeyUp;

- (void)requestToolChangeNotification;

@end
