//
//  PXInfoPanelController.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXInfoPanelController.h"

@implementation PXInfoPanelController

@synthesize cursorX, cursorY, width, height, red, green, blue, alpha, hex;
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
	[width setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"WIDTH", @"Width"), (int)(size.width)]];
	[height setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"HEIGHT", @"Height"), (int)(size.height)]];
}

- (void)setColorInfo:(NSColor *)color
{
	if (color)
	{
		color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		
		[red setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"RED", @"Red"), (int) roundf([color redComponent] * 255)]];
		[green setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"GREEN", @"Green"), (int) roundf([color greenComponent] * 255)]];
		[blue setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"BLUE", @"Blue"), (int) roundf([color blueComponent] * 255)]];
		[alpha setStringValue:[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"ALPHA", @"Alpha"), (int) roundf([color alphaComponent] * 255)]];
		[hex setStringValue:[NSString stringWithFormat:@"%@: #%02X%02X%02X", NSLocalizedString(@"Hex", @"Hex"), (int) roundf([color redComponent] * 255), (int) roundf([color greenComponent] * 255), (int) roundf([color blueComponent] * 255)]];
	}
	else
	{
		[red setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"RED", @"Red")]];
		[green setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"GREEN", @"Green")]];
		[blue setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"BLUE", @"Blue")]];
		[alpha setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"ALPHA", @"Alpha")]];
		[hex setStringValue:[NSString stringWithFormat:@"%@: --", NSLocalizedString(@"Hex", @"Hex")]];
	}
}

- (void)setCursorPosition:(NSPoint)point
{
	NSPoint difference = point;
	difference.x -= _draggingOrigin.x;
	difference.y -= _draggingOrigin.y;
	
	if (difference.x > 0.1 || difference.x < -0.1) {
		[cursorX setStringValue:[NSString stringWithFormat:@"X: %d (%@%d)", (int)(point.x), difference.x >= 0 ? @"+" : @"", (int)(difference.x)]];
	} 
	else {
		[cursorX setStringValue:[NSString stringWithFormat:@"X: %d", (int)(point.x)]];
	}
	
	if (difference.y > 0.1 || difference.y < -0.1) {
		[cursorY setStringValue:[NSString stringWithFormat:@"Y: %d (%@%d)", (int)(point.y), difference.y >= 0 ? @"+" : @"", (int)(difference.y)]];
	}
	else {
		[cursorY setStringValue:[NSString stringWithFormat:@"Y: %d", (int)(point.y)]];
	}
}

@end

