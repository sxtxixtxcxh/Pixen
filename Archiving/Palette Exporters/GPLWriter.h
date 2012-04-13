//
//  GPLWriter.h
//  Pixen
//
//  Created by Collin Sanford on 4/5/12.
//  Copyright 2012 Collin Sanford. All rights reserved.
//

#import "PXPalette.h"

@interface GPLWriter : NSObject

+ (id)sharedGPLWriter;

- (NSData *)palDataForPalette:(PXPalette *)palette;

@end
