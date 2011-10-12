//
//  OSJASCPALReader.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@interface OSJASCPALReader : NSObject

+ (id)sharedJASCPALReader;

- (PXPalette *)paletteWithData:(NSData *)data;

@end
