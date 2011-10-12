//
//  OSACTWriter.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@interface OSACTWriter : NSObject

+ (id)sharedACTWriter;

- (NSData *)palDataForPalette:(PXPalette *)palette;

@end
