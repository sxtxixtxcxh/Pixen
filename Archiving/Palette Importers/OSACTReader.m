//
//  OSACTReader.m
//  PALExport
//
//  Created by Andy Matuschak on 8/16/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "OSACTReader.h"


@implementation OSACTReader

- init
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
	if ([data length] != 768)
	{
		[NSException raise:@"OSFileError" format:@"This is an invalid ACT palette: normal ACT palettes are exactly 768 bytes long; this one is %d", [data length]];
		return NULL;
	}
	PXPalette *palette = [[PXPalette alloc] initWithoutBackgroundColor];
	palette.name = @"Imported palette";
	int i;
	const unsigned char *bytes = [data bytes];
	for (i = 0; i < 256; i++)
	{
		int red, green, blue;
		red = bytes[i * 3 + 0];
		green = bytes[i * 3 + 1];
		blue = bytes[i * 3 + 2];
		
#warning TODO: do bucket check
		// There's a bunch of black at the end of the file to pad it to 768 bytes; if we already have a black color in our palette and we find another black, it means that the file is over.
		if ((red == 0) && (green == 0) && (blue == 0) /*&& PXPalette_bucketForColor(palette, [[NSColor blackColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace])*/)
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
		[palette addColor:[NSColor colorWithCalibratedRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1]];
	}
	return palette;
}

@end
