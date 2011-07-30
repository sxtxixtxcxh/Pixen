//
//  PXPreferencesController.h
//  Pixen
//

#import <AppKit/AppKit.h>

@class PXGeneralPreferencesController, PXHotkeysPreferencesController;

typedef enum {
	PXPreferencesTabGeneral = 0,
	PXPreferencesTabHotkeys
} PXPreferencesTab;

@interface PXPreferencesController : NSWindowController
{
  @private
	PXGeneralPreferencesController *_generalVC;
	PXHotkeysPreferencesController *_hotkeysVC;
	PXPreferencesTab _selectedTab;
}

+ (id)sharedPreferencesController;

- (IBAction)selectGeneralTab:(id)sender;
- (IBAction)selectHotkeysTab:(id)sender;

@end
