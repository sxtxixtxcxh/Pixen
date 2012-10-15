//
//  PXCanvasWindowController_Zooming.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasWindowController.h"

@interface PXCanvasWindowController (Zooming)

- (void)zoomToPercent:(int)percent;
- (void)zoomToFit;

- (void)canvasController:(PXCanvasController *)controller zoomInOnCanvasPoint:(NSPoint)point;
- (void)canvasController:(PXCanvasController *)controller zoomOutOnCanvasPoint:(NSPoint)point;
- (void)zoomToFitCanvasController:(PXCanvasController *)controller;

- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)zoomStandard:(id)sender;
- (IBAction)zoomToFit:(id)sender;

- (IBAction)zoomSliderChanged:(id)sender;

@end
