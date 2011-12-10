//
//  PXGridSettingsController.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXGridSettingsController.h"

#import "PXDefaults.h"

@implementation PXGridSettingsController

@synthesize colorWell = _colorWell, shouldDrawCheckBox = _shouldDrawCheckBox, colorLabel = _colorLabel, sizeLabel = _sizeLabel;
@synthesize width = _width, height = _height, color = _color, shouldDraw = _shouldDraw, delegate = _delegate;

- (id)init
{
	return [super initWithWindowNibName:@"PXGridSettings"];
}

- (void)dealloc
{
	self.color = nil;
	[super dealloc];
}

- (void)showWindow:(id)sender
{
	[super showWindow:sender];
	[self update:nil];
}

- (IBAction)update:(id)sender
{
	if ([self.shouldDrawCheckBox state] == NSOnState)
	{
		[self.sizeLabel setTextColor:[NSColor blackColor]];
		[self.colorLabel setTextColor:[NSColor blackColor]];
	}
	else
	{
		if ([self.colorWell isActive])
		{
			[[NSColorPanel sharedColorPanel] close];
		}
		
		[self.sizeLabel setTextColor:[NSColor disabledControlTextColor]];
		[self.colorLabel setTextColor:[NSColor disabledControlTextColor]];
	}
	
	if ([self.delegate respondsToSelector:@selector(gridSettingsController:updatedWithSize:color:shouldDraw:)])
	{
		[self.delegate gridSettingsController:self
						 updatedWithSize:NSMakeSize(self.width, self.height)
								   color:self.color
							  shouldDraw:self.shouldDraw];
	}
}

- (IBAction)useAsDefaults:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setBool:self.shouldDraw forKey:PXGridShouldDrawKey];
	[defaults setFloat:self.width forKey:PXGridUnitWidthKey];
	[defaults setFloat:self.height forKey:PXGridUnitHeightKey];
	[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.color]
				 forKey:PXGridColorDataKey];
	
	[self update:self];
}

- (IBAction)displayHelp:(id)sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"grid" inBook:@"Pixen Help"];
}

- (void)windowWillClose:(NSNotification *)notification
{
	if ([self.colorWell isActive])
	{
		[[NSColorPanel sharedColorPanel] close];
	}
}

@end
