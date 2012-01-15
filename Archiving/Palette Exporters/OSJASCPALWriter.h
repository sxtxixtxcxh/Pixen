//
//  OSJASCPALWriter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@interface OSJASCPALWriter : NSObject

+ (id)sharedJASCPALWriter;

- (NSData *)palDataForPalette:(PXPalette *)palette;

@end
