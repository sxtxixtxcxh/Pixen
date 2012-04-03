//
//  PXCanvasWindowController.m
//  Pixen
//

#import "PXDocumentController.h"

#import "PXAnimationWindowController.h"
#import "PXCanvasWindowController.h"
#import "PXCanvasWindowController_Toolbar.h"
#import "PXCanvasWindowController_Zooming.h"
#import "PXCanvasWindowController_IBActions.h"
#import "PXCanvasController.h"
#import "PXCanvas_Layers.h"
#import "PXCanvasView.h"
#import "PXLayerController.h"
#import "PXCanvasResizePrompter.h"
#import "PXScaleController.h"
#import "PXCanvasDocument.h"
#import "PXInfoPanelController.h"
#import "PXPaletteController.h"
#import "PXPreviewController.h"

//Taken from a man calling himself "BROCK BRANDENBERG" 
//who is here to save the day.
#import "SBCenteringClipView.h"

@implementation PXCanvasWindowController

@synthesize scaleController, canvasController, resizePrompter = _resizePrompter, canvas;
@synthesize splitView, layerSplit, canvasSplit, paletteSplit;


- (PXCanvasView *)view
{
	return [canvasController view];
}

- (id) initWithWindowNibName:name
{
	if (! ( self = [super initWithWindowNibName:name] ) ) 
		return nil;
	layerController = [[PXLayerController alloc] init];
	[layerController setNextResponder:self];
	paletteController = [[PXPaletteController alloc] init];

	return self;
}

- (PXScaleController *)scaleController
{
	if (!scaleController) {
		scaleController = [[PXScaleController alloc] init];
	}
	
	return scaleController;
}

- (PXCanvasResizePrompter *)resizePrompter
{
	if (!_resizePrompter) {
		_resizePrompter = [[PXCanvasResizePrompter alloc] init];
		_resizePrompter.delegate = self;
		
		[_resizePrompter loadWindow];
	}
	
	return _resizePrompter;
}

- (void)canvasResizePrompter:(PXCanvasResizePrompter *)prompter didFinishWithSize:(NSSize)size
					position:(NSPoint)position backgroundColor:(NSColor *)color
{
	[canvas setSize:size withOrigin:position backgroundColor:PXColorFromNSColor(color)];
	[canvasController updateCanvasSize];
}

- (NSView*)layerSplit;
{
	return layerSplit;
}

- (NSView*)canvasSplit;
{
	return canvasSplit;
}

- (void)awakeFromNib
{
	NSView *paletteView = [paletteController view];
	[paletteSplit addSubview:paletteView];
	[canvasController setLayerController:layerController];
	[layerSplit addSubview:[layerController view]];
	[self updateFrameSizes];
	[self prepareToolbar];
	[[self window] setAcceptsMouseMovedEvents:YES];
}

- (void)updateFrameSizes
{
	[[layerController view] setFrameSize:[layerSplit frame].size];
	[[layerController view] setFrameOrigin:NSZeroPoint];

	[[paletteController view] setFrameSize:[paletteSplit frame].size];
	[[paletteController view] setFrameOrigin:NSZeroPoint];
	[[canvasController scrollView] setFrameOrigin:NSZeroPoint];
	[[canvasController scrollView] setFrameSize:[[self canvasSplit] frame].size];
}

- (void)dealloc
{
	[canvasController deactivate];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[layerController release];
	[_resizePrompter release];
	[scaleController release];
	[toolbar release];
	
	[super dealloc];
}

- (void)windowWillClose:note
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self setCanvas:nil];
	[_gridSettingsController close];
}

- (void)releaseCanvas
{
	canvas = nil;
	[canvasController setCanvas:nil];
}

- (void)setCanvas:(PXCanvas *) aCanvas
{
	if (canvas != aCanvas) {
		canvas = aCanvas;
		[canvasController setCanvas:canvas];
	}
}

- (void)setDocument:(NSDocument *)doc
{
	[super setDocument:doc];
	[canvasController setDocument:doc];
	[paletteController setDocument:doc];
}

- (void)windowDidResignMain:note
{
	if ([note object] == [self window])
	{
		[canvasController deactivate];
	}
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	if ([notification object] == [self window])
	{
		[canvasController activate];
		[self updateFrameSizes];
		[[PXInfoPanelController sharedInfoPanelController] setCanvasSize:[canvas size]];
		
		//FIXME: tight coupling
		if ([self isKindOfClass:[PXAnimationWindowController class]]) {
			[[PXPreviewController sharedPreviewController] setAnimation:[ (PXAnimationWindowController *) self animation]];
		}
		else {
			[[PXPreviewController sharedPreviewController] setSingleCanvas:canvas];
		}
	}
}

- (void)prepare
{
	[self prepareZoom];
	
	[canvasController setDocument:[self document]];
	[canvasController setWindow:[self window]];
	[canvasController prepare];
	
	[self zoomToFit:self];
	
	[[self window] useOptimizedDrawing:YES];
}

- (void)updateCanvasSize
{
	[canvasController updateCanvasSize];
}

- (void)mouseMoved:event
{
	[[canvasController view] mouseMoved:event];
}

- (void)flagsChanged:event
{
	[canvasController flagsChanged:event];
}

- (void)rightMouseUp:event
{
	[canvasController rightMouseUp:event];
}

- (void)rightMouseDown:event
{
	if(NSPointInRect([event locationInWindow], [[canvasController view] convertRect:[[canvasController view] bounds] toView:nil])) {
		[[canvasController view] rightMouseDown:event];
	}
}

- (void)rightMouseDragged:event
{
	[[canvasController view] rightMouseDragged:event];
}

- (void)mouseUp:event
{
	[[canvasController view] mouseUp:event];
}

- (void)mouseDown:event
{
	if(NSPointInRect([event locationInWindow], [[canvasController view] convertRect:[[canvasController view] bounds] toView:nil])) {
		[[canvasController view] mouseDown:event];
	}
}

- (void)mouseDragged:event
{
	[[canvasController view] mouseDragged:event];
}

- (void)keyDown:event
{
	if([paletteController isPaletteIndexKey:event])
	{
		[paletteController keyDown:event];
	}
	[canvasController keyDown:event];
}

//- (void)undo:sender { [[[self document] windowController] undo]; }
//- (void)redo:sender { [[[self document] windowController] redo]; }
//- (void)performMiniaturize:sender { [[self window] performMiniaturize:sender]; }
//- (void)toggleToolbarShown:sender { [[self window] toggleToolbarShown:sender]; }
//- (void)runToolbarCustomizationPalette:sender { [[self window] runToolbarCustomizationPalette:sender]; }
//- (void)performClose:sender
//{
//	[window performClose:sender];
//}


- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	BOOL v = [[self window] validateMenuItem:anItem];
	NSUndoManager *manager = [[self document] undoManager];
	if ([anItem action] == @selector(undo:))
	{
		[anItem setTitleWithMnemonic:[manager undoMenuItemTitle]];
		return [manager canUndo];
	}
	if ([anItem action] == @selector(redo:))
	{
		[anItem setTitleWithMnemonic:[manager redoMenuItemTitle]];
		return [manager canRedo];
	}
	return v;
}

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview {
	return (subview != canvasSplit);
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
	if (view == sidebarSplit)
		return NO;
	
	return YES;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin
				 ofSubviewAt:(NSInteger)offset { 
	if(sender == splitView) {
		return 210;
	}
	return 110;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax 
				 ofSubviewAt:(NSInteger)offset {
	if(sender == splitView) {
		return 400;
	}
	return sender.frame.size.height-110;
}


//this is to fix a bug in animation documents where expanding the
//split subview trashes the dimensions of the layer control view
- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
	[self updateFrameSizes];
}

@end
