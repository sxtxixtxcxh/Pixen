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

@property (nonatomic, assign) NSControlSize colorControlSize;

+ (id)popWithPalette:(PXPalette *)palette fromWindow:(NSWindow *)window;
- (id)initWithPalette:(PXPalette *)palette;

- (PXPaletteView *)paletteView;

@end
