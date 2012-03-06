//
//  PXHotkeysPreferencesController.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXHotkeysPreferencesController.h"

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
		PXHotkeyFormatter *formatter = [[PXHotkeyFormatter alloc] init];
		formatter.delegate = self;
		
		[currentCell setFormatter:formatter];
		[formatter release];
	}
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

@end
