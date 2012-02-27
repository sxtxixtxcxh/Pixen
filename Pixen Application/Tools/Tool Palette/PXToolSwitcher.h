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
	PXFillToolTag,
	PXLineToolTag,
	PXRectangularSelectionToolTag,
	PXMoveToolTag,
	PXRectangleToolTag,
	PXEllipseToolTag,
	PXMagicWandToolTag,
	PXLassoToolTag
} PXToolTag;


@interface PXToolSwitcher : NSObject
{
  @private
	NSMutableArray *tools;
	IBOutlet NSMatrix *toolsMatrix;
	IBOutlet NSColorWell *colorWell;
	
	NSColor *_color;
	PXTool *_tool;
	PXTool *_lastTool;
	BOOL _locked;
}

- (id) init;
- (id) selectedTool;

- (id) toolWithTag:(PXToolTag)tag;
- (PXToolTag)tagForTool:(id) aTool;
- (void)setIcon:(NSImage *) anImage forTool:(id)aTool;
- (void)clearBeziers;

	//Manage color/colorWell
- (NSColor*) color;
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

- (void)checkUserDefaults;

- (void)requestToolChangeNotification;

@end
