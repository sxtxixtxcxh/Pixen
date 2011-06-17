//
//  PXGeneralPreferencesController.m
//  Pixen
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "PXGeneralPreferencesController.h"

#import "PXDocumentController.h"

@implementation PXGeneralPreferencesController

- (id)init
{
	self = [super initWithNibName:@"PXGeneralPreferences" bundle:nil];
	return self;
}

- (void)awakeFromNib
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults boolForKey:PXAutosaveEnabledKey]) {
		[autoBackupFrequency setEnabled:YES];
	}
	else {
		[autoBackupFrequency setEnabled:NO];
	}
}

- (IBAction)switchAutoBackup:(id)sender
{
	[self updateAutoBackup:sender];
	
	if ([sender state] == NSOnState) {
		[autoBackupFrequency setEnabled:YES];
	}
	else {
		[autoBackupFrequency setEnabled:NO];
	}
}

- (IBAction)updateAutoBackup:(id)sender
{
	[(PXDocumentController *)[NSDocumentController sharedDocumentController] rescheduleAutosave];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[(PXDocumentController *)[NSDocumentController sharedDocumentController] rescheduleAutosave];
}

@end
