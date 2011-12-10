//
//  PXPalettePanel.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@class PXPaletteView, PXPaletteViewController;

@interface PXPalettePanel : NSPanel
{
	PXPaletteViewController *_vc;
}

+ (id)popWithPalette:(PXPalette *)palette fromWindow:(NSWindow *)window;
- (id)initWithPalette:(PXPalette *)palette;

- (PXPaletteView *)paletteView;

@end
