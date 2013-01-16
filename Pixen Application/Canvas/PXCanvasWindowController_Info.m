//
//  PXCanvasWindowController_Toolbar.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasWindowController_Info.h"

#import "PXInfoView.h"

@implementation PXCanvasWindowController(Info)

- (void)setCanvasSize:(NSSize)size
{
	self.infoView.width = (int)(size.width);
	self.infoView.height = (int)(size.height);
}

- (void)draggingOriginChanged:(NSNotification *)notification
{
	[self setDraggingOrigin:[[[notification userInfo] valueForKey:@"draggingOrigin"] pointValue]];
}

- (void)cursorPositionChanged:(NSNotification *)notification
{
	NSPoint point = [[[notification userInfo] valueForKey:@"cursorPoint"] pointValue];
	NSPoint difference = point;
	difference.x -= [self draggingOrigin].x;
	difference.y -= [self draggingOrigin].y;
	
//	if (difference.x > 0.1 || difference.x < -0.1) {
//		self.infoView.cursorX = (int)(difference.x);
//	}
//	else {
		self.infoView.cursorX = (int)(point.x);
//	}
	
//	if (difference.y > 0.1 || difference.y < -0.1) {
//		self.infoView.cursorY = (int)(difference.y);
//	}
//	else {
		self.infoView.cursorY = (int)(point.y);
//	}
}

- (void)canvasColorChanged:(NSNotification *)notification
{
	self.infoView.hasColor = YES;
	
	PXColor color;
	
	NSData *colorData = [[notification userInfo] valueForKey:@"currentColor"];
	[colorData getBytes:&color length:sizeof(color)];
	
	self.infoView.color = color;
}

- (void)canvasNoColorChanged:(NSNotification *)notification
{
	self.infoView.hasColor = NO;
}

@end
