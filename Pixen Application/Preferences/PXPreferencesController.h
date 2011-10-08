//
//  PXPreferencesController.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

typedef enum {
	PXPreferencesTabGeneral = 0,
	PXPreferencesTabHotkeys
} PXPreferencesTab;

@interface PXPreferencesController : NSWindowController

+ (id)sharedPreferencesController;

- (IBAction)selectGeneralTab:(id)sender;
- (IBAction)selectHotkeysTab:(id)sender;

@end
