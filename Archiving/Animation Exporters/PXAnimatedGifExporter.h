//
//  PXAnimatedGifExporter.h
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "gif_lib.h"

@class PXCanvas, PXPalette;

@interface PXAnimatedGifExporter : NSObject
{
  @private
	NSString *_temporaryPath;
	GifFileType *_gifFile;
	
	ColorMapObject *_colorMap;
	int _colorCount;
	int _transparencyIndex;
	
	NSSize _size;
}

- (id)initWithSize:(NSSize)size palette:(PXPalette *)palette;

- (BOOL)writeCanvas:(PXCanvas *)canvas withDuration:(NSTimeInterval)duration;

- (NSData *)finalizeExport;

@end
