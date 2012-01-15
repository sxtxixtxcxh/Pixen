//
//  PXGeneralPreferencesController.m
//  Pixen
//
//  Copyright Matt Rajca 2012. All rights reserved.
//

#import "PXGeneralPreferencesController.h"

#import "PXDocumentController.h"

@implementation PXGeneralPreferencesController

@synthesize autoBackupFrequency = _autoBackupFrequency;

- (id)init
{
	self = [super initWithNibName:@"PXGeneralPreferences" bundle:nil];
	return self;
}

- (void)dealloc
{
	self.autoBackupFrequency = nil;
	[super dealloc];
}

- (void)awakeFromNib
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults boolForKey:PXAutosaveEnabledKey]) {
		[self.autoBackupFrequency setEnabled:YES];
	}
	else {
		[self.autoBackupFrequency setEnabled:NO];
	}
}

- (IBAction)switchAutoBackup:(id)sender
{
	[self updateAutoBackup:sender];
	
	if ([sender state] == NSOnState) {
		[self.autoBackupFrequency setEnabled:YES];
	}
	else {
		[self.autoBackupFrequency setEnabled:NO];
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
