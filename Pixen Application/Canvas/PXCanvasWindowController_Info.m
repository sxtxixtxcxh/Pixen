//
//  PXCanvasWindowController_Toolbar.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasWindowController_Info.h"

@implementation PXCanvasWindowController(Info)

- (IBAction)nextInfoButtonTitle:(id)sender
{
	[self setInfoMode:[self infoMode] + 1];
	if ([self infoMode] > 2) {
		[self setInfoMode:0];
	}
	
	[self updateInfoButtonTitle];
}

- (void)updateInfoButtonTitle
{
	NSString *newInfoString = [NSString stringWithFormat:@"%@: %lu %@: %lu",
							   NSLocalizedString(@"WIDTH_ABBR", @"Width"),
							   [self width],
							   NSLocalizedString(@"HEIGHT_ABBR", @"Height"),
							   [self height]];
	
	if ([self infoMode] == PXCanvasInfoModeDimensionsAndPosition || [self infoMode] == PXCanvasInfoModeDimensionsAndPositionAndColor) {
		newInfoString = [newInfoString stringByAppendingFormat:@"    X: %ld Y: %ld", [self cursorX], [self cursorY]];
	}
	if ([self infoMode] == PXCanvasInfoModeDimensionsAndPositionAndColor) {
		if (![self pointerHasColor]) {
			newInfoString = [newInfoString stringByAppendingFormat:@"    --"];
		} else {
			newInfoString = [newInfoString stringByAppendingFormat:@"    Hex: %@    RGBA: (%lu, %lu, %lu, %lu)",
							 [self hex],
							 [self red],
							 [self green],
							 [self blue],
							 [self alpha]];
		}
	}
	
	[[self infoButton] setTitle:newInfoString];
	[[self infoButton] sizeToFit];
}

- (void)setCanvasSize:(NSSize)size
{
	[self setWidth:(int)(size.width)];
	[self setHeight:(int)(size.height)];
	[self updateInfoButtonTitle];
}

- (void)draggingOriginChanged:(NSNotification *)notification
{
	[self setDraggingOrigin:[[[notification userInfo] valueForKey:@"draggingOrigin"] pointValue]];
	[self updateInfoButtonTitle];
}

- (void)cursorPositionChanged:(NSNotification *)notification
{
	NSPoint point = [[[notification userInfo] valueForKey:@"cursorPoint"] pointValue];
	NSPoint difference = point;
	difference.x -= [self draggingOrigin].x;
	difference.y -= [self draggingOrigin].y;
	
	if (difference.x > 0.1 || difference.x < -0.1) {
		[self setCursorX:(int)(difference.x)];
	}
	else {
		[self setCursorX:(int)(point.x)];
	}
	
	if (difference.y > 0.1 || difference.y < -0.1) {
		[self setCursorY:(int)(difference.y)];
	}
	else {
		[self setCursorY:(int)(point.y)];
	}
	[self updateInfoButtonTitle];
}

- (void)canvasColorChanged:(NSNotification *)notification
{
	[self setPointerHasColor:YES];
	
	PXColor color;
	
	NSData *colorData = [[notification userInfo] valueForKey:@"currentColor"];
	[colorData getBytes:&color length:sizeof(color)];
	
	[self setRed:color.r];
	[self setGreen:color.g];
	[self setBlue:color.b];
	[self setAlpha:color.a];
	[self setHex:[NSString stringWithFormat:@"#%02X%02X%02X", color.r, color.g, color.b]];
	[self updateInfoButtonTitle];
}

- (void)canvasNoColorChanged:(NSNotification *)notification
{
	[self setPointerHasColor:NO];
	[self updateInfoButtonTitle];
}

@end
