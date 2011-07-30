//
//  PXGridSettingsController.m
//  Pixen
//

#import "PXGridSettingsController.h"
#import "PXDefaults.h"

@implementation PXGridSettingsController

@synthesize width, height, color, shouldDraw, delegate;

- (id)init
{
	if ( ! ( self = [super initWithWindowNibName:@"PXGridSettings"] ))
		return nil;
	
	return self;
}

- (void)showWindow:(id)sender
{
	[super showWindow:sender];
	[self update:nil];
}

- (IBAction)update:(id)sender
{
	if ([shouldDrawCheckBox state] == NSOnState) {
		[sizeLabel setTextColor:[NSColor blackColor]];
		[colorLabel setTextColor:[NSColor blackColor]];
	} else {
		if ([colorWell isActive])
			[[NSColorPanel sharedColorPanel] close];
		
		[sizeLabel setTextColor:[NSColor disabledControlTextColor]];
		[colorLabel setTextColor:[NSColor disabledControlTextColor]];
	}
	
	[delegate gridSettingsController:self
					 updatedWithSize:NSMakeSize(self.width, self.height)
							   color:self.color
						  shouldDraw:self.shouldDraw];
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
