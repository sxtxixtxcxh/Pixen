//
//  PXPaletteExporter.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@interface PXPaletteExporter : NSObject < NSOpenSavePanelDelegate >

- (void)runWithPalette:(PXPalette *)palette inWindow:(NSWindow *)window;

@end
