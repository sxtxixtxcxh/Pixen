//
//  PXColorPicker.h
//  PXColorPicker
//
//  Created by Andy Matuschak on 7/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern int kPXColorPickerMode;

@class PXPaletteViewController;

@interface PXColorPicker : NSColorPicker <NSColorPickingDefault, NSColorPickingCustom>
{
  @private
	PXPaletteViewController *_vc;
	NSImage *_icon;
}

@end
