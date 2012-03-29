//
//  PXCanvasController.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXColor.h"

@class PXCanvas, PXCanvasView, PXBackground, PXLayerController, PXBackgroundController;

@interface PXCanvasController : NSObject
{
  @private
	PXCanvas *canvas;
	IBOutlet PXCanvasView *view;
	IBOutlet NSScrollView *scrollView;
	NSDocument *document;
	IBOutlet NSWindow *window;
	
	PXLayerController *layerController;
	PXBackgroundController *backgroundController;
	
	NSPoint initialPoint;
	NSPoint lastDrawnPoint;
	BOOL downEventOccurred;
	BOOL usingSpaceKey;
	
	NSPoint panLeftovers; // used to integerify the pan coords
	
	PXColor oldColor;
	
	id delegate;
	BOOL wraps; // used in setCanvas
}

@property (nonatomic, assign) id delegate;

- (PXCanvasView *)view;
- (NSScrollView *)scrollView;
- (PXLayerController *)layerController;
- window;
- (void)setLayerController:contro;
- (void)prepare;
- (void)toolSwitched:(NSNotification *)notification;
- (void)canvasSizeDidChange:(NSNotification *) aNotification;
- (PXCanvas *) canvas;
- (void)setCanvas:(PXCanvas *)canv;
- (void)canvasDidChange:(NSNotification *) aNotification;
- (void)activate;
- (void)deactivate;
- (void)updatePreview;
- mainBackground;
- alternateBackground;
- (void)setMainBackground:(id) aBackground;
- (void)setAlternateBackground:(id) aBackground;
- (PXBackground *)defaultMainBackground;
- (void)setDefaultMainBackground:(PXBackground *)bg;
- (PXBackground *)defaultAlternateBackground;
- (void)setDefaultAlternateBackground:(PXBackground *)bg;
- (void)toggleShouldTile;
- (void)setPatternToSelection;
- (void)showBackgroundInfo;
- (void)updateCanvasSizeZoomingToFit:(BOOL)zooming;
- (void)updateCanvasSize;
- document;
- (void)setDocument:doc;
- window;
- (void)setWindow:win;
- (void)zoomInOnCanvasPoint:(NSPoint)point;
- (void)zoomOutOnCanvasPoint:(NSPoint)point;

- (void)mouseDown:event forTool:aTool;
- (void)mouseDragged:(NSEvent *)event forTool:aTool;
- (void)mouseUpAt:(NSPoint)loc forTool:aTool;
- (void)mouseMovedTo:(NSPoint)point forTool:aTool;
- (void)updateMousePosition:(NSPoint)newLocation;
- (void)mouseDown:(NSEvent *)event;
- (void)eraserDown:(NSEvent *)event;
- (void)eraserDragged:(NSEvent *)event;
- (void)eraserUp:(NSEvent *)event;
- (void)eraserMoved:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *) event;
- (void)mouseMoved:(NSEvent *) event;
- (void)mouseUp:(NSEvent *) event;
- (void)rightMouseDown:(NSEvent *) event;
- (void)rightMouseDragged:(NSEvent *) event;
- (void)rightMouseUp:(NSEvent *) event;
- (void)scrollWheel:(NSEvent *)event;
- (void)otherMouseDragged:(NSEvent *)event;
- (void)keyUp:(NSEvent *)event;
- (void)keyDown:(NSEvent *)event;
- (void)flagsChanged:(NSEvent *) event;
- (void)panViewWithEvent:(NSEvent *)event;
- (BOOL)caresAboutPressure;

- (void)setLastDrawnPoint:(NSPoint)point;
- (NSPoint)lastDrawnPoint;

@end


@interface NSObject(PXCanvasControllerDelegate)

- (void)canvasController:(PXCanvasController *)controller zoomInOnCanvasPoint:(NSPoint)point;
- (void)canvasController:(PXCanvasController *)controller zoomOutOnCanvasPoint:(NSPoint)point;
- (void)zoomToFitCanvasController:(PXCanvasController *)controller;

@end
