//
//  PXGridSettingsController.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXGridSettingsController.h"

#import "PXDefaults.h"

@implementation PXGridSettingsController

@synthesize colorWell = _colorWell, colorLabel = _colorLabel, sizeLabel = _sizeLabel;
@synthesize width = _width, height = _height, color = _color, delegate = _delegate;

- (id)init
{
	return [super initWithWindowNibName:@"PXGridSettings"];
}

- (void)setNilValueForKey:(NSString *)key
{
	if ([key isEqualToString:@"width"]) {
		[self setValue:[NSNumber numberWithInt:1] forKey:@"width"];
	}
	else if ([key isEqualToString:@"height"]) {
		[self setValue:[NSNumber numberWithInt:1] forKey:@"height"];
	}
	else {
		[super setNilValueForKey:key];
	}
}

- (void)showWindow:(id)sender
{
	[super showWindow:sender];
	[self update:nil];
}

- (IBAction)update:(id)sender
{
	[self.delegate gridSettingsController:self
						  updatedWithSize:NSMakeSize(self.width, self.height)
									color:self.color];
}

- (IBAction)useAsDefaults:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setFloat:self.width forKey:PXGridUnitWidthKey];
	[defaults setFloat:self.height forKey:PXGridUnitHeightKey];
	[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.color]
				 forKey:PXGridColorDataKey];
	
	[self update:self];
}

- (void)windowWillClose:(NSNotification *)notification
{
	if ([self.colorWell isActive])
	{
		[[NSColorPanel sharedColorPanel] close];
	}
}

@end
