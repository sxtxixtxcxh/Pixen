//
//  PXPaletteImporter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXPaletteImporter : NSObject
{
	NSOpenPanel *_openPanel;
}

- (void)importPaletteAtPath:(NSString *)path;

- (void)runInWindow:(NSWindow *)window;

@end
