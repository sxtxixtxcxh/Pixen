//
//  PXColorPicker.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@class PXPaletteViewController;

@interface PXColorPicker : NSColorPicker < NSColorPickingDefault, NSColorPickingCustom >
{
	PXPaletteViewController *_vc;
	NSImage *_icon;
}

@end
