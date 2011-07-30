//
//  PXPaletteImporter.h
//  Pixen
//
//  Created by Andy Matuschak on 8/22/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXPaletteImporter : NSObject {
  @private
	NSOpenPanel *openPanel;
}

- (void)importPaletteAtPath:(NSString *)path;
- (void)runInWindow:(NSWindow *)window;

@end
