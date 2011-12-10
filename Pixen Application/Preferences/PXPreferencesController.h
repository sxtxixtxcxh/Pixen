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

@class PXGeneralPreferencesController;
@class PXHotkeysPreferencesController;

@interface PXPreferencesController : NSWindowController
{
	PXGeneralPreferencesController *_generalVC;
	PXHotkeysPreferencesController *_hotkeysVC;
	PXPreferencesTab _selectedTab;
}

+ (id)sharedPreferencesController;

- (IBAction)selectGeneralTab:(id)sender;
- (IBAction)selectHotkeysTab:(id)sender;

@end
