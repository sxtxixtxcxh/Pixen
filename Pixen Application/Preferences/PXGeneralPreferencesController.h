//
//  PXGeneralPreferencesController.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

@interface PXGeneralPreferencesController : NSViewController
{
    NSTextField *_autoBackupFrequency;
}

@property (nonatomic, assign) IBOutlet NSTextField *autoBackupFrequency;

- (IBAction)switchAutoBackup:(id)sender;
- (IBAction)updateAutoBackup:(id)sender;

@end
