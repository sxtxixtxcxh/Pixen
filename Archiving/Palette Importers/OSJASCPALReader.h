//
//  OSJASCPALReader.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@interface OSJASCPALReader : NSObject

+ (id)sharedJASCPALReader;

- (PXPalette *)paletteWithData:(NSData *)data;

@end
