//
//  PXPalettePanel.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@class PXPaletteView, PXPaletteViewController;

@interface PXPalettePanel : NSPanel
{
  @private
	PXPaletteViewController *_vc;
}

+ (id)popWithPalette:(PXPalette *)palette fromWindow:(NSWindow *)window;
- (id)initWithPalette:(PXPalette *)palette;

- (PXPaletteView *)paletteView;

@end
