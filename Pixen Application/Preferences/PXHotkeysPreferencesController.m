//
//  PXHotkeysPreferencesController.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXHotkeysPreferencesController.h"

#import "PXToolSwitcher.h"

@interface PXHotkeysPreferencesController ()

- (NSString *)classNameForToolWithTag:(PXToolTag)tag;

@end


@implementation PXHotkeysPreferencesController

@synthesize form = _form;

- (id)init
{
	return [super initWithNibName:@"PXHotkeysPreferences" bundle:nil];
}

- (void)dealloc
{
	self.form = nil;
	[super dealloc];
}

- (void)awakeFromNib
{
	for (NSCell *currentCell in [self.form cells])
	{
		NSString *toolClassName = [self classNameForToolWithTag: (PXToolTag) [currentCell tag]];
		NSString *hotkey = [[NSUserDefaults standardUserDefaults] stringForKey:toolClassName];
		
		[currentCell setStringValue:hotkey];
		
		PXHotkeyFormatter *formatter = [[PXHotkeyFormatter alloc] init];
		formatter.delegate = self;
		
		[currentCell setFormatter:formatter];
		[formatter release];
	}
}

- (NSString *)classNameForToolWithTag:(PXToolTag)tag
{
	return [[[PXToolSwitcher toolClasses] objectAtIndex:tag] className];
}

- (BOOL)hotkeyFormatter:(PXHotkeyFormatter *)formatter isCharacterTaken:(unichar)character
{
	for (NSCell *currentCell in [self.form cells])
	{
		NSString *hotkey = [currentCell stringValue];
		
		if ([hotkey length]) {
			if ([hotkey characterAtIndex:0] == character) {
				NSBeep();
				return YES;
			}
		}
	}
	
	return NO;
}

- (IBAction)updateCell:(id)sender
{
	id cell = [sender cellAtIndex:[sender indexOfSelectedItem]];
	
	[[NSUserDefaults standardUserDefaults] setObject:[cell stringValue]
											  forKey:[self classNameForToolWithTag: (PXToolTag) [cell tag]]];
}

@end
