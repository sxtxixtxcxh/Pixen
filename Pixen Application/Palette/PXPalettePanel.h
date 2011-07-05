//
//  PXPalettePanel.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.12.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXPalette.h"

@class PXPaletteView, PXPaletteViewController;

@interface PXPalettePanel : NSPanel < NSWindowDelegate > {
  @private
	PXPaletteViewController *_vc;
}

+ (id)popWithPalette:(PXPalette *)palette fromWindow:(NSWindow *)window;
- (id)initWithPalette:(PXPalette *)palette;

- (PXPaletteView *)paletteView;

@end
