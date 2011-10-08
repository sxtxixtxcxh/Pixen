//
//  PXGeneralPreferencesController.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

@interface PXGeneralPreferencesController : NSViewController

@property (nonatomic, retain) IBOutlet NSTextField *autoBackupFrequency;

- (IBAction)switchAutoBackup:(id)sender;
- (IBAction)updateAutoBackup:(id)sender;

@end
