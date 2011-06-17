//
//  PXGeneralPreferencesController.h
//  Pixen
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PXGeneralPreferencesController : NSViewController
{
  @private
	IBOutlet NSTextField *autoBackupFrequency;
}

- (IBAction)switchAutoBackup:(id)sender;
- (IBAction)updateAutoBackup:(id)sender;

@end
