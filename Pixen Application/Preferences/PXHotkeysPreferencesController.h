//
//  PXHotkeysPreferencesController.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXHotkeyFormatter.h"

@interface PXHotkeysPreferencesController : NSViewController < PXHotkeyFormatterDelegate >
{
  @private
	NSForm *_form;
}

@property (nonatomic, assign) IBOutlet NSForm *form;

- (IBAction)updateCell:(id)sender;

@end
