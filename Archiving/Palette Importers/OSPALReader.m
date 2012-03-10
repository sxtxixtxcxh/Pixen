//
//  OSPALReader.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
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
		int red = bytes[24 + (i * 4) + 0];
		int green = bytes[24 + (i * 4) + 1];
		int blue = bytes[24 + (i * 4) + 2];
		
		[palette addColor:PXColorMake(red, green, blue, 255)];
	}
	return [palette autorelease];
}

@end
