//
//  PXGeneralPreferencesController.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

@interface PXGeneralPreferencesController : NSViewController

@property (nonatomic, assign) IBOutlet NSTextField *autoBackupFrequency;

- (IBAction)switchAutoBackup:(id)sender;
- (IBAction)updateAutoBackup:(id)sender;

@end
