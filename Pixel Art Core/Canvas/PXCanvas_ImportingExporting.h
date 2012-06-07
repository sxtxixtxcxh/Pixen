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

- (NSImage *)exportImageWithBackgroundColor:(NSColor *)color;
- (NSImage *)exportImage; // suitable for writing to file
- (NSImageRep *)exportImageRep;
- (NSImage *)displayImage; // suitable for drawing to the screen

@end
