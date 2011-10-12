//
//  OSPALReader.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@interface OSPALReader : NSObject

+ (id)sharedPALReader;

- (PXPalette *)paletteWithData:(NSData *)data;

@end
