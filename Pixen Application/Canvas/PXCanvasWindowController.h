//  PXCanvasWindowController.h
//  Pixen
//
//  Created by Joe Osborn on Sat Sep 13 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//
#import <AppKit/AppKit.h>

@class PXCanvasController, PXScaleController, PXCanvas, PXCanvasView, PXBackground, RBSplitView, RBSplitSubview;

@interface PXCanvasWindowController : NSWindowController
{
  @private
	PXCanvas *canvas;

	IBOutlet id zoomPercentageBox;
	IBOutlet id zoomStepper;
	IBOutlet NSView *zoomView;
	id previewController;
	id resizePrompter;
	PXScaleController *scaleController;
	id layerController;
	
	id paletteController;
	
	id toolbar;
	IBOutlet PXCanvasController *canvasController;
	IBOutlet RBSplitView *splitView;
	IBOutlet RBSplitSubview *layerSplit, *canvasSplit, *paletteSplit;
}

@property (nonatomic, readonly) IBOutlet PXCanvasController *canvasController;
@property (nonatomic, readonly) PXScaleController *scaleController;

@property (nonatomic, assign) PXCanvas *canvas;

- (PXCanvasView *)view;
- (id) initWithWindowNibName:name;
- (void)awakeFromNib;
- (RBSplitSubview*)layerSplit;
- (RBSplitSubview*)canvasSplit;
- (void)dealloc;
- (void)windowWillClose:note;
- (void)releaseCanvas;
- (void)setDocument:(NSDocument *)doc;
- (void)windowDidResignMain:note;
- (void)windowDidBecomeMain:(NSNotification *) aNotification;
- (void)prepare;
- (void)updatePreview;
- (void)updateCanvasSize;
- (void)updateFrameSizes;
@end
