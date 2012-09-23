//
//  PXPreferencesController.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

typedef enum {
	PXPreferencesTabGeneral = 0,
	PXPreferencesTabHotkeys
} PXPreferencesTab;

@class PXGeneralPreferencesController;
@class PXHotkeysPreferencesController;

@interface PXPreferencesController : NSWindowController < NSWindowRestoration >
{
  @private
	PXGeneralPreferencesController *_generalVC;
	PXHotkeysPreferencesController *_hotkeysVC;
	PXPreferencesTab _selectedTab;
}

+ (PXPreferencesController *)sharedPreferencesController;

- (IBAction)selectGeneralTab:(id)sender;
- (IBAction)selectHotkeysTab:(id)sender;

@end
