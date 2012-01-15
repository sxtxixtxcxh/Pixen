//
//  PXBitmapImporter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXBitmapImporter : NSObject

+ (id)sharedBitmapImporter;

- (NSArray *)colorsInBMPData:(NSData *)data;

@end
