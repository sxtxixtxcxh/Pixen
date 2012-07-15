//
//  OSJASCPALReader.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "OSJASCPALReader.h"

@implementation OSJASCPALReader

- (id)init
{
	[NSException raise:@"SingletonError" format:@"OSJASCPALReader is a singleton; use sharedJASCPALReader to access the shared instance."];
	return nil;
}

- (id)_init
{
	self = [super init];
	return self;
}

+ (id)sharedJASCPALReader
{
	static OSJASCPALReader *sharedJASCPALReader = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedJASCPALReader = [[OSJASCPALReader alloc] _init];
	});
	
	return sharedJASCPALReader;
}

- (PXPalette *)paletteWithData:(NSData *)data
{
	NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	NSScanner *scanner = [NSScanner scannerWithString:string];
	if (![scanner scanString:@"JASC-PAL\n0100\n" intoString:nil])
	{
		[NSException raise:@"OSFileError" format:@"This JASC-PAL has an invalid header or unsupported version (this object supports only 0100)"];
		return NULL;
	}
	int colorCount;
	if (![scanner scanInt:&colorCount])
	{
		[NSException raise:@"OSFileError" format:@"Couldn't read color count from JASC PAL data"];
		return NULL;
	}
	PXPalette *palette = [[PXPalette alloc] initWithoutBackgroundColor];
	palette.name = @"Imported palette";
	int i;
	for (i = 0; i < colorCount; i++)
	{
		int red, green, blue;
		if (![scanner scanInt:&red])
		{
			[NSException raise:@"OSFileError" format:@"Couldn't read color JASC PAL data (color #%d)", i];
			return NULL;
		}
		if (![scanner scanInt:&green])
		{
			[NSException raise:@"OSFileError" format:@"Couldn't read color JASC PAL data (color #%d)", i];
			return NULL;
		}
		if (![scanner scanInt:&blue])
		{
			[NSException raise:@"OSFileError" format:@"Couldn't read color JASC PAL data (color #%d)", i];
			return NULL;
		}
		[palette addColor:PXColorMake(red, green, blue, 255)];
	}
	return palette;
}

@end
