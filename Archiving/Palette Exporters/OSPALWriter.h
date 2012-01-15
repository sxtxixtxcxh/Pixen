//
//  OSPALWriter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@interface OSPALWriter : NSObject

+ (id)sharedPALWriter;

- (NSData *)palDataForPalette:(PXPalette *)palette;

@end
