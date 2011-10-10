//
//  NSColor+PXPaletteAdditions.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import <AppKit/NSColor.h>

@interface NSColor (PXPaletteAdditions)

- (unsigned int)paletteHash;
- (float)distanceTo:(NSColor *)other;

@end
