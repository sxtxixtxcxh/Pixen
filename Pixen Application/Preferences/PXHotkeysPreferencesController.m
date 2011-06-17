//
//  PXHotkeysPreferencesController.m
//  Pixen
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "PXHotkeysPreferencesController.h"

#import "PXHotkeyFormatter.h"

@implementation PXHotkeysPreferencesController

- (id)init
{
	self = [super initWithNibName:@"PXHotkeysPreferences" bundle:nil];
	return self;
}

- (void)awakeFromNib
{
	for (NSCell *currentCell in [form cells])
	{
		[currentCell setFormatter:[[[PXHotkeyFormatter alloc] init] autorelease]];
	}
}

@end
