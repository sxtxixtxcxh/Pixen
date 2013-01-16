//  PXCanvasWindowController.h
//  Pixen
//
//  Created by Joe Osborn on Sat Sep 13 2003.
//  Copyright (c) 2003 Pixen. All rights reserved.
//

#import "PXCanvasResizePrompter.h"

@class PXCanvasController, PXGridSettingsController, PXLayerController, PXPaletteController, PXScaleController;
@class PXCanvas, PXCanvasView, PXBackground, PXDocument, PXInfoView;

@interface PXCanvasWindowController : NSWindowController < PXCanvasResizePrompterDelegate >
{
  @private
	PXCanvasController *__weak canvasController;
	PXCanvas *__weak canvas;
	
	PXGridSettingsController *_gridSettingsController;
	PXCanvasResizePrompter *_resizePrompter;
	PXScaleController *scaleController;
	PXLayerController *layerController;
	PXPaletteController *paletteController;
	
	NSToolbar *toolbar;
}

@property (nonatomic, weak) IBOutlet NSTextField *zoomLabel;
@property (nonatomic, weak) IBOutlet NSSlider *zoomSlider;
@property (nonatomic, weak) IBOutlet PXInfoView *infoView;
@property (nonatomic, assign) NSPoint draggingOrigin;

@property (nonatomic, weak) IBOutlet PXCanvasController *canvasController;

@property (nonatomic, strong, readonly) PXScaleController *scaleController;
@property (nonatomic, strong, readonly) PXCanvasResizePrompter *resizePrompter;

@property (nonatomic, weak) PXCanvas *canvas;

@property (nonatomic, weak) IBOutlet NSSplitView *splitView;
@property (nonatomic, weak) IBOutlet NSView *sidebarSplit, *layerSplit, *canvasSplit, *paletteSplit;

- (PXCanvasView *)view;
- (NSView *)layerSplit;
- (NSView *)canvasSplit;
- (void)windowWillClose:note;
- (void)releaseCanvas;
- (void)setDocument:(PXDocument *)doc;
- (void)windowDidResignMain:note;
- (void)windowDidBecomeMain:(NSNotification *) aNotification;
- (void)prepare;
- (void)updateCanvasSize;
- (void)updateFrameSizes;

@end
