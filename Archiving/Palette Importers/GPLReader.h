//
//  GPLReader.h
//  Pixen
//
//  Created by Collin Sanford on 4/4/12.
//  Copyright 2012 Collin Sanford. All rights reserved.
//

@class PXPalette;

@interface GPLReader : NSObject

+ (id)sharedGPLReader;

- (PXPalette *)paletteWithData:(NSData *)data;

@end
