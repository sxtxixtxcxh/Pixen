//
//  PXPaletteExporter.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@interface PXPaletteExporter : NSObject < NSOpenSavePanelDelegate >
{
	NSSavePanel *_savePanel;
	NSPopUpButton *_typeSelector;
	PXPalette *_palette;
}

- (void)runWithPalette:(PXPalette *)palette inWindow:(NSWindow *)window;

@end
