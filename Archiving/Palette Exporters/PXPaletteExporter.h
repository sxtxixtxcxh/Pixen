//
//  PXPaletteExporter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@interface PXPaletteExporter : NSObject < NSOpenSavePanelDelegate >
{
  @private
	NSSavePanel *_savePanel;
	NSPopUpButton *_typeSelector;
	PXPalette *_palette;
}

- (void)runWithPalette:(PXPalette *)palette inWindow:(NSWindow *)window;

@end
