//
//  PXInfoPanelController.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXInfoPanelController.h"

@implementation PXInfoPanelController

@synthesize cursorX = _cursorX, cursorY = _cursorY, width = _width, height = _height;
@synthesize red = _red, green = _green, blue = _blue, alpha = _alpha, hex = _hex;
@synthesize draggingOrigin = _draggingOrigin;

- (id)init
{
	return [super initWithWindowNibName:@"PXInfoPanel"];
}

- (void)windowDidLoad
{
	[ (NSPanel *) self.window setBecomesKeyOnlyIfNeeded:YES];
	[self.window setFrameAutosaveName:PXInfoPanelFrameAutosaveName];
}

+ (id)sharedInfoPanelController
{
	static PXInfoPanelController *singleInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		singleInstance = [[self alloc] init];
	});
	
	return singleInstance;
}

- (void)setCanvasSize:(NSSize)size
{
	[self.width setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"WIDTH", @"Width"), (int)(size.width)]];
	[self.height setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"HEIGHT", @"Height"), (int)(size.height)]];
}

- (void)setColorInfo:(PXColor)color
{
	[self.red   setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"RED", @"Red"),     color.r]];
	[self.green setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"GREEN", @"Green"), color.g]];
	[self.blue  setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"BLUE", @"Blue"),   color.b]];
	[self.alpha setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"ALPHA", @"Alpha"), color.a]];
	[self.hex   setStringValue:[NSString stringWithFormat:@"%@: #%02X%02X%02X", NSLocalizedString(@"Hex", @"Hex"),
								color.r, color.g, color.b, color.a]];
}

- (void)setNoColorInfo
{
	[self.red   setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"RED", @"Red")]];
	[self.green setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"GREEN", @"Green")]];
	[self.blue  setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"BLUE", @"Blue")]];
	[self.alpha setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"ALPHA", @"Alpha")]];
	[self.hex   setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"Hex", @"Hex")]];
}

- (void)setCursorPosition:(NSPoint)point
{
	NSPoint difference = point;
	difference.x -= _draggingOrigin.x;
	difference.y -= _draggingOrigin.y;
	
	if (difference.x > 0.1 || difference.x < -0.1) {
		[self.cursorX setStringValue:[NSString stringWithFormat:@"X: %d (%@%d)", (int)(point.x), difference.x >= 0 ? @"+" : @"", (int)(difference.x)]];
	} 
	else {
		[self.cursorX setStringValue:[NSString stringWithFormat:@"X: %d", (int)(point.x)]];
	}
	
	if (difference.y > 0.1 || difference.y < -0.1) {
		[self.cursorY setStringValue:[NSString stringWithFormat:@"Y: %d (%@%d)", (int)(point.y), difference.y >= 0 ? @"+" : @"", (int)(difference.y)]];
	}
	else {
		[self.cursorY setStringValue:[NSString stringWithFormat:@"Y: %d", (int)(point.y)]];
	}
}

@end

