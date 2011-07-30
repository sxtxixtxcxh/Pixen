//
//  PXInfoPanelController.m
//  Pixen
//


#import "PXInfoPanelController.h"

#import <Foundation/NSUserDefaults.h>

#import <AppKit/NSColor.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSPanel.h>
#import <AppKit/NSTextField.h>


@implementation PXInfoPanelController


- (id)init
{
	if ( ! (self = [super init] ))
		return nil;
	
	if ( ! [NSBundle loadNibNamed:@"PXInfoPanel" owner:self])
	{
		[self release];
		return nil;
	}
	
	return self;
}

-(void) awakeFromNib
{
	[panel setBecomesKeyOnlyIfNeeded: YES];
	[panel setFrameAutosaveName:PXInfoPanelFrameAutosaveName];
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

- (void)setColorInfo:(NSColor *) color
{
	if (color)
	{
		//if ([color colorSpaceName] != NSCalibratedRGBColorSpace)
		color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace]; 
				
		[red setStringValue:
			[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"RED", @"Red"), (int) roundf([color redComponent] * 255)]];
		[green setStringValue:
			[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"GREEN", @"Green"), (int) roundf([color greenComponent] * 255)]];
		[blue setStringValue:
			[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"BLUE", @"Blue"), (int) roundf([color blueComponent] * 255)]];
		[alpha setStringValue:
			[NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"ALPHA", @"Alpha"), (int) roundf([color alphaComponent] * 255)]];
		[hex setStringValue:
			[NSString stringWithFormat:@"%@: #%02X%02X%02X", NSLocalizedString(@"Hex", @"Hex"), (int) roundf([color redComponent] * 255), (int) roundf([color greenComponent] * 255), (int) roundf([color blueComponent] * 255)]];
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

- (void)setDraggingOrigin:(NSPoint)point
{
	draggingOrigin = point;
}

- (void)setCursorPosition:(NSPoint)point
{
	NSPoint difference = point;
	difference.x -= draggingOrigin.x;
	difference.y -= draggingOrigin.y;
	
	if ( ( difference.x > 0.1 )  ||  ( difference.x < -0.1 ) ) {
		[cursorX setStringValue:
			[NSString stringWithFormat:@"X: %d (%@%d)", (int)(point.x), difference.x >= 0 ? @"+" : @"", (int)(difference.x)]];
	} 
	else {
		[cursorX setStringValue:[NSString stringWithFormat:@"X: %d", (int)(point.x)]];
	}
	
	if (difference.y > 0.1 || difference.y < -0.1) {
		[cursorY setStringValue:
			[NSString stringWithFormat:@"Y: %d (%@%d)", (int)(point.y), difference.y >= 0 ? @"+" : @"", (int)(difference.y)]];
	} 
	else {
		[cursorY setStringValue:[NSString stringWithFormat:@"Y: %d", (int)(point.y)]];
	}
}

//Accessor
-(NSPanel *) infoPanel
{
	return panel;
}

@end

