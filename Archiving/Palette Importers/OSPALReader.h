//
//  OSPALReader.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@interface OSPALReader : NSObject

+ (id)sharedPALReader;

- (PXPalette *)paletteWithData:(NSData *)data;

@end
