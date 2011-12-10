//
//  PXColorPicker.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@class PXPaletteViewController;

@interface PXColorPicker : NSColorPicker < NSColorPickingDefault, NSColorPickingCustom >
{
	PXPaletteViewController *_vc;
	NSImage *_icon;
}

@end
