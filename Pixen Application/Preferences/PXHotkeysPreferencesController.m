//
//  PXHotkeysPreferencesController.m
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

#import "PXHotkeysPreferencesController.h"

#import "PXHotkeyFormatter.h"

@implementation PXHotkeysPreferencesController

@synthesize form = _form;

- (id)init
{
	self = [super initWithNibName:@"PXHotkeysPreferences" bundle:nil];
	return self;
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
		[currentCell setFormatter:[[[PXHotkeyFormatter alloc] init] autorelease]];
	}
}

@end
