//
//  OSJASCPALWriter.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@interface OSJASCPALWriter : NSObject

+ (id)sharedJASCPALWriter;

- (NSData *)palDataForPalette:(PXPalette *)palette;

@end
