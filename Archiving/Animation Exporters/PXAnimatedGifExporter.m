//
//  PXAnimatedGifExporter.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXAnimatedGifExporter.h"

#import "gif_lib.h"
#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXPalette.h"

#define GIF_ITERATION_HEADER "NETSCAPE2.0"
#define GIF_ITERATION_LENGTH 3

#define GIF_VERSION "89a"

@interface PXAnimatedGifExporter ()

- (ColorMapObject *)colorMapWithPalette:(PXPalette *)palette colorCount:(int *)outColorCount mapSize:(int *)outMapSize;
- (BOOL)writeHeaderUsingColorMap:(ColorMapObject *)colorMap ofSize:(int)mapSize;

@end


@implementation PXAnimatedGifExporter

- (id)initWithSize:(NSSize)size palette:(PXPalette *)palette
{
	NSParameterAssert(palette);
	
	self = [super init];
	if (self)
	{
		EGifSetGifVersion(GIF_VERSION);
		
		_transparencyIndex = -1;
		
		int mapSize = 0;
		_colorMap = [self colorMapWithPalette:palette colorCount:&_colorCount mapSize:&mapSize];
		
		if (!_colorMap)
		{
			NSLog(@"Failed to generate a color map for the GIF animation");
			[self release];
			return nil;
		}
		
		_temporaryPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"pxa_gif_export.gif"] retain];
		_gifFile = EGifOpenFileName([_temporaryPath UTF8String], NO);
		_size = size;
		
		if (![self writeHeaderUsingColorMap:_colorMap ofSize:mapSize])
		{
			NSLog(@"Failed to write the header of the GIF animation");
			
			[self finalizeExport];
			[self release];
			
			return nil;
		}
	}
	return self;
}

- (void)dealloc
{
	[_temporaryPath release];
	
	if (_colorMap)
		FreeMapObject(_colorMap);
	
	[super dealloc];
}

- (ColorMapObject *)colorMapWithPalette:(PXPalette *)palette colorCount:(int *)outColorCount mapSize:(int *)outMapSize
{
	// The animated GIF writer only supports <= 256 color palettes. If you have a palette bigger than that, quantize it first then come back.
	if ([palette colorCount] > 256)
	{
		[NSException raise:NSInternalInconsistencyException format:@"PXAnimatedGifExporter requires <= 256 colors in the palette."];
		return NULL;
	}
	
	int colorCount = (int) [palette colorCount];
	
	// If we're using alpha, we have to remove all the colors in the palette with alpha < .5 and replace them with a single color entry for the previously-determined transparent color.
	// In order to do that, we must first go through and find how many colors we're -really- going to have.
	int colorMapSize = 0;
	BOOL hasAlpha = NO;
	
	for (int i = 0; i < colorCount; i++)
	{
		// We're only including colors that are (or will be) opaque
		if ([palette colorAtIndex:i].a > 127) {
			colorMapSize++;
		}
		else {
			hasAlpha = YES;
		}
	}
	
	if (hasAlpha)
		colorMapSize++; // Add one more color at the end for the transparency index
	
	// Set up the GIF color map. It has to be a power of two size.
	int mapSize = MAX(pow(2, ceilf(log2(colorMapSize))), 2);
	ColorMapObject *colorMap = MakeMapObject(mapSize, NULL);
	
	if (colorMap == NULL)
	{
		[NSException raise:NSInternalInconsistencyException format:@"Couldn't allocate the color map."];
		return NULL;
	}
	
	int mapIndex = 0;
	
	for (int i = 0; i < colorCount; i++)
	{
		// Check to see if the current color is transparent; if so, don't deal with it now: we'll add the sole transparent color at the end.
		PXColor color = [palette colorAtIndex:i];
		
		if (color.a <= 127)
			continue;
		
		colorMap->Colors[mapIndex].Red = color.a;
		colorMap->Colors[mapIndex].Green = color.g;
		colorMap->Colors[mapIndex].Blue = color.b;
		
		mapIndex++;
	}
	
	// If we're using alpha, we add a color to be used as transparent.
	if (hasAlpha)
	{
		colorMap->Colors[mapIndex].Red = 255;
		colorMap->Colors[mapIndex].Green = 255;
		colorMap->Colors[mapIndex].Blue = 255;
		
		_transparencyIndex = mapIndex;
	}
	
	if (outColorCount)
		*outColorCount = colorMapSize;
	
	if (outMapSize)
		*outMapSize = mapSize;
	
	return colorMap;
}

- (BOOL)writeHeaderUsingColorMap:(ColorMapObject *)colorMap ofSize:(int)mapSize
{
	char iterationString[GIF_ITERATION_LENGTH] = { 0x01, 0, 0 };
	
	if (EGifPutScreenDesc(_gifFile, (int) _size.width, (int) _size.height, mapSize, 0, colorMap) == GIF_ERROR)
		return NO;
	
	if (EGifPutExtensionFirst(_gifFile, 0xFF, strlen(GIF_ITERATION_HEADER), GIF_ITERATION_HEADER) == GIF_ERROR)
		return NO;
	
	if (EGifPutExtensionLast(_gifFile, 0, GIF_ITERATION_LENGTH, iterationString) == GIF_ERROR)
		return NO;
	
	return YES;
}

- (BOOL)writeCanvas:(PXCanvas *)canvas withDuration:(NSTimeInterval)duration
{
	int w = (int) _size.width, h = (int) _size.height;
	
	// We will now actually populate the output buffer with the indices
	GifByteType *outputBuffer = malloc(w * h * sizeof(GifByteType));
	
	int bufferIndex = 0;
	
	for (int j = h - 1; j >= 0; j--)
	{
		for (int i = 0; i < w; i++, bufferIndex++)
		{
			NSPoint point = NSMakePoint(i, j);
			
			if ([canvas mergedColorAtPoint:point].a <= 127) { // transparent colors
				outputBuffer[bufferIndex] = _transparencyIndex;
			}
			else
			{
				// opaque colors
				PXColor color = [canvas mergedColorAtPoint:point];
				
				for (int mapIndex = 0; mapIndex < _colorCount; mapIndex++)
				{
					if (color.r == _colorMap->Colors[mapIndex].Red && color.g == _colorMap->Colors[mapIndex].Green && color.b == _colorMap->Colors[mapIndex].Blue)
					{
						outputBuffer[bufferIndex] = mapIndex;
						break;
					}
				}
			}
		}
	}
	
	int tempDuration = (int) roundf(duration * 100);
	
	unsigned char extension[4] = { 0 };
	extension[0] = 9;                  // byte 1 is a flag; 00000001 turns transparency on.
	extension[1] = tempDuration % 256; // byte 2 is delay time, presumably for animation.
	extension[2] = tempDuration / 256; // byte 3 is continued delay time.
	extension[3] = _transparencyIndex; // byte 4 is the index of the transparent color in the palette.
	
	if (EGifPutExtension(_gifFile, 0xF9, sizeof(extension), extension) == GIF_ERROR) // 0xF9 is the transparency extension magic code
	{
		free(outputBuffer);
		NSLog(@"Couldn't write the GIF image extension block");
		return NO;
	}
	
	if (EGifPutImageDesc(_gifFile, 0, 0, w, h, 0, NULL) == GIF_ERROR)
	{
		free(outputBuffer);
		NSLog(@"Couldn't write the GIF image description");
		return NO;
	}
	
	GifByteType *position = outputBuffer;
	
	for (int i = 0; i < h; i++)
	{
		if (EGifPutLine(_gifFile, position, w) == GIF_ERROR)
		{
			free(outputBuffer);
			NSLog(@"Couldn't write the GIF line number %d", i);
			return NO;
		}
		
		position += w;
	}
	
	free(outputBuffer);
	
	return YES;
}

- (NSData *)finalizeExport
{
	if (_gifFile) {
		EGifCloseFile(_gifFile);
		_gifFile = NULL;
	}
	
	NSData *data = [NSData dataWithContentsOfFile:_temporaryPath];
	remove([_temporaryPath UTF8String]);
	
	return data;
}

@end
