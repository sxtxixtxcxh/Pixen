//
//  PXGridSettingsController.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXGridSettingsController.h"

#import "PXDefaults.h"

@implementation PXGridSettingsController

@synthesize colorWell, shouldDrawCheckBox, colorLabel, sizeLabel;
@synthesize width, height, color, shouldDraw, delegate;

- (id)init
{
	return [super initWithWindowNibName:@"PXGridSettings"];
}

- (void)dealloc
{
	[color release];
	[super dealloc];
}

- (void)showWindow:(id)sender
{
	[super showWindow:sender];
	[self update:nil];
}

- (IBAction)update:(id)sender
{
	if ([shouldDrawCheckBox state] == NSOnState)
	{
		[sizeLabel setTextColor:[NSColor blackColor]];
		[colorLabel setTextColor:[NSColor blackColor]];
	}
	else
	{
		if ([colorWell isActive])
		{
			[[NSColorPanel sharedColorPanel] close];
		}
		
		[sizeLabel setTextColor:[NSColor disabledControlTextColor]];
		[colorLabel setTextColor:[NSColor disabledControlTextColor]];
	}
	
	if ([delegate respondsToSelector:@selector(gridSettingsController:updatedWithSize:color:shouldDraw:)])
	{
		[delegate gridSettingsController:self
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
	if ([colorWell isActive])
	{
		[[NSColorPanel sharedColorPanel] close];
	}
}

@end
