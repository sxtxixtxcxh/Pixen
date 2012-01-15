//
//  OSACTReader.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@class PXPalette;

@interface OSACTReader : NSObject

+ (id)sharedACTReader;

- (PXPalette *)paletteWithData:(NSData *)data;

@end
