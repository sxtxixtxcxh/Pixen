//
//  OSPALReader.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "OSPALReader.h"

@implementation OSPALReader

- (id)init
{
	[NSException raise:@"SingletonError" format:@"OSPALReader is a singleton; use sharedPALReader to access the shared instance."];
	return nil;
}

- (id)_init
{
	self = [super init];
	return self;
}

+ (id)sharedPALReader
{
	static OSPALReader *sharedPALReader = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedPALReader = [[OSPALReader alloc] _init];
	});
	
	return sharedPALReader;
}

- (PXPalette *)paletteWithData:(NSData *)data
{
	const unsigned char * bytes = [data bytes];
	if (bytes[0] != 'R' || bytes[1] != 'I' || bytes[2] != 'F' || bytes[3] != 'F')
	{
		[NSException raise:@"OSFileError" format:@"Passed data does not contain a Microsoft palette"];
		return NULL;
	}
	int colorCount = bytes[22] + (bytes[23] * 256);
	int i;
	PXPalette *palette = [[PXPalette alloc] initWithoutBackgroundColor];
	palette.name = @"Imported palette";
	for (i = 0; i < colorCount; i++)
	{
		float red = bytes[24 + (i * 4) + 0] / 255.0;
		float green = bytes[24 + (i * 4) + 1] / 255.0;
		float blue = bytes[24 + (i * 4) + 2] / 255.0;
		[palette addColor:[NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1]];
	}
	return [palette autorelease];
}

@end
