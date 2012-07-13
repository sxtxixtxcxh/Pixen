//
//  PXCanvas_ImportingExporting.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvas.h"

@interface PXCanvas (ImportingExporting)

+ (id)canvasWithContentsOfFile:(NSString *)aFile;

- (id)initWithContentsOfFile:(NSString *)aFile;
- (id)initWithImage:(NSImage *)anImage;

- (NSData *)imageDataWithType:(NSBitmapImageFileType)storageType properties:(NSDictionary *)properties;

- (void)replaceActiveLayerWithImage:(NSImage *)anImage;

- (NSBitmapImageRep *)imageRep; // suitable for drawing to the screen

@end
