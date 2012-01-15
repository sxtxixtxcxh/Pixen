//
//  OSACTWriter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@interface OSACTWriter : NSObject

+ (id)sharedACTWriter;

- (NSData *)palDataForPalette:(PXPalette *)palette;

@end
