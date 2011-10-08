//
//  PXBitmapImporter.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@interface PXBitmapImporter : NSObject

+ (id)sharedBitmapImporter;

- (NSArray *)colorsInBMPData:(NSData *)data;

@end
