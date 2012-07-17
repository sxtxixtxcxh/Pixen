//
//  PXGridSettingsController.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXGridSettingsController.h"

#import "PXDefaults.h"

@implementation PXGridSettingsController

@synthesize colorWell = _colorWell;
@synthesize showGrid = _showGrid, width = _width, height = _height, color = _color, delegate = _delegate;

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

- (void)beginSheetWithParentWindow:(NSWindow *)parentWindow
{
	[NSApp beginSheet:[self window] modalForWindow:parentWindow modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
	
	[self update:nil];
}

- (IBAction)update:(id)sender
{
	[self.delegate gridSettingsController:self
						  updatedWithSize:NSMakeSize(self.width, self.height)
									color:self.color
								  visible:self.showGrid];
}

- (IBAction)useAsDefaults:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setFloat:self.width forKey:PXGridUnitWidthKey];
	[defaults setFloat:self.height forKey:PXGridUnitHeightKey];
	[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.color]
				 forKey:PXGridColorDataKey];
	[defaults setBool:self.showGrid forKey:PXGridShouldDrawKey];
	
	[self update:self];
}

- (IBAction)dismiss:(id)sender
{
	[NSApp endSheet:[self window]];
	[self.window orderOut:nil];
}

- (void)windowWillClose:(NSNotification *)notification
{
	if ([self.colorWell isActive])
	{
		[[NSColorPanel sharedColorPanel] close];
	}
}

@end
