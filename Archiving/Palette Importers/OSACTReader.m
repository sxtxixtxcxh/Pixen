//
//  OSACTReader.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "OSACTReader.h"

#import "PXPalette.h"

@implementation OSACTReader

- (id)init
{
	[NSException raise:@"SingletonError" format:@"OSACTReader is a singleton; use sharedACTReader to access the shared instance."];
	return nil;
}

- (id)_init
{
	self = [super init];
	return self;
}

+ (id)sharedACTReader
{
	static OSACTReader *sharedACTReader = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedACTReader = [[OSACTReader alloc] _init];
	});
	
	return sharedACTReader;
}

- (PXPalette *)paletteWithData:(NSData *)data
{
	if ([data length] != 768 && [data length] != 772)
	{
		[NSException raise:@"OSFileError" format:@"This is an invalid ACT palette: normal ACT palettes are exactly 768 or 772 bytes long; this one is %ld", [data length]];
		return NULL;
	}
	
	int expectedColorCount = -1;
	
	if ([data length] == 772) {
		uint16_t c = 0;
		[data getBytes:&c range:NSMakeRange(768, 2)];
		
		expectedColorCount = NSSwapBigShortToHost(c);
	}
	
	PXPalette *palette = [[PXPalette alloc] initWithoutBackgroundColor];
	palette.name = @"Imported palette";
	int i;
	const unsigned char *bytes = [data bytes];
	for (i = 0; i < 256; i++)
	{
		if (i == expectedColorCount)
			break;
		
		int red, green, blue;
		red = bytes[i * 3 + 0];
		green = bytes[i * 3 + 1];
		blue = bytes[i * 3 + 2];
		
		// There's a bunch of black at the end of the file to pad it to 768 bytes; if we already have a black color in our palette and we find another black, it means that the file is over.
		if ((red == 0) && (green == 0) && (blue == 0) && [palette indexOfColor:PXGetBlackColor()] != NSNotFound)
		{
			// If the rest of the file is black, break.
			int j = 0;
			BOOL shouldBreak = YES;
			for (j = i+1; j < 256; j++)
			{
				if ((bytes[j * 3 + 0] != 0) || (bytes[j * 3 + 1] != 0) || (bytes[j * 3 + 2] != 0))
				{
					shouldBreak = NO;
					break;
				}
			}
			if (shouldBreak)
				break;
		}
		[palette addColor:PXColorMake(red, green, blue, 255)];
	}
	return palette;
}

@end
