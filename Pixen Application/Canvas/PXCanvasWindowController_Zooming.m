//
//  PXCanvasWindowController_Zooming.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasWindowController_Zooming.h"

#import "PXCanvas.h"
#import "PXCanvasView.h"
#import "PXCanvasController.h"

@implementation PXCanvasWindowController (Zooming)

- (void)zoomToPercent:(int)percent
{
	[canvasController view].zoomPercentage = percent;
	
	[self.zoomLabel setStringValue:[NSString stringWithFormat:@"%d%%", percent]];
	[self.zoomSlider setIntValue:percent];
}

- (void)zoomToFit
{
	if ([canvas size].width <= 0 || [canvas size].height <= 0)
		return;
	
	NSRect contentFrame = [[[canvasController scrollView] contentView] frame];
	
	CGFloat xRatio = NSWidth(contentFrame) / [canvas size].width;
	CGFloat yRatio = NSHeight(contentFrame) / [canvas size].height;
	
	int pct = 100;
	
	if ((NSWidth(contentFrame) > [canvas size].width || NSHeight(contentFrame) > [canvas size].height)) {
		pct = floorf(xRatio < yRatio ? xRatio : yRatio) * 100;
	}
	
	[self zoomToPercent:MIN(pct, 1000)];
}

- (void)canvasController:(PXCanvasController *)controller zoomInOnCanvasPoint:(NSPoint)point
{
	[self zoomIn:self];
}

- (void)canvasController:(PXCanvasController *)controller zoomOutOnCanvasPoint:(NSPoint)point
{
	[self zoomOut:self];
}

- (void)zoomToFitCanvasController:(PXCanvasController *)controller
{
	[self zoomToFit:self];
}

- (IBAction)zoomIn:(id)sender
{
	int currentZoom = [canvasController view].zoomPercentage;
	
	if (currentZoom < 1000)
		[self zoomToPercent:(currentZoom + 100)];
}

- (IBAction)zoomOut:(id)sender
{
	int currentZoom = [canvasController view].zoomPercentage;
	
	if (currentZoom > 100)
		[self zoomToPercent:(currentZoom - 100)];
}

- (IBAction)zoomStandard:(id)sender
{
	[self zoomToPercent:100];
}

- (IBAction)zoomToFit:(id)sender
{
	[self zoomToFit];
}

- (IBAction)zoomSliderChanged:(id)sender
{
	int closestZoom = roundf([sender intValue] / 100.0f) * 100;
	
	[self zoomToPercent:closestZoom];
}

@end
