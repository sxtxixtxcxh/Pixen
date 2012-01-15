//
//  NSColor+PXPaletteAdditions.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import <AppKit/NSColor.h>

@interface NSColor (PXPaletteAdditions)

- (unsigned int)paletteHash;
- (float)distanceTo:(NSColor *)other;

@end
