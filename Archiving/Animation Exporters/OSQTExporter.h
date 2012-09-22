//
//  OSQTExporter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface OSQTExporter : NSObject

- (BOOL)beginExportToURL:(NSURL *)url size:(NSSize)size;
- (BOOL)addImageRep:(NSBitmapImageRep *)imageRep forLength:(NSTimeInterval)seconds;
- (void)finishExport;

@end
