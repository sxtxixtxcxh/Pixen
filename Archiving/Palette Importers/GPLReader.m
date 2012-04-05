//
//  GPLReader.m
//  Pixen
//
//  Created by Collin Sanford on 4/4/12.
//  Copyright 2012 Collin Sanford. All rights reserved.
//

#import "GPLReader.h"
#import "PXPalette.h"


@implementation GPLReader

- (id)init
{
	[NSException raise:@"SingletonError" format:@"GPLReader is a singleton; use sharedGPLReader to access the shared instance."];
	return nil;
}

- (id)_init
{
	self = [super init];
	return self;
}

+ (id)sharedGPLReader
{
	static GPLReader *sharedGPLReader = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedGPLReader = [[GPLReader alloc] _init];
	});
	
	return sharedGPLReader;
}

- (PXPalette *)paletteWithData:(NSData *)data
{
	NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	NSScanner *scanner = [NSScanner scannerWithString:string];
    NSString *error = @"Couldn't read GPL color data";
	[string release];
	if (![scanner scanString:@"GIMP Palette\n" intoString:nil])
	{
		[NSException raise:@"OSFileError" format:@"This GPL file has an invalid header"];
		return NULL;
	}
    NSString *paletteName;
	if (![scanner scanString:@"Name:" intoString:NULL]
        || ![scanner scanUpToString:@"\n" intoString:&paletteName])
	{
		[NSException raise:@"OSFileError" format:@"Couldn't read color count from JASC PAL data"];
		return NULL;
	}
	PXPalette *palette = [[PXPalette alloc] initWithoutBackgroundColor];
	palette.name = paletteName;
    if (![scanner scanUpToString:@"#\n" intoString:NULL] ||
        ![scanner scanString:@"#\n" intoString:NULL]) {
        [NSException raise:@"OSFileError" format:@"Couldn't read color count from JASC PAL data"];
		return NULL;
    }
    while ([scanner isAtEnd] == NO) {
		int red, green, blue;
		if (![scanner scanInt:&red])
		{
			[NSException raise:@"OSFileError" format:error];
			return NULL;
		}
		if (![scanner scanInt:&green])
		{
			[NSException raise:@"OSFileError" format:error];
			return NULL;
		}
		if (![scanner scanInt:&blue])
		{
			[NSException raise:@"OSFileError" format:error];
			return NULL;
		}
		[palette addColor:PXColorMake(red, green, blue, 255)];
        [scanner scanUpToString:@"\n" intoString:NULL];
        [scanner scanString:@"\n" intoString:NULL];
	}
	return [palette autorelease];
}

@end
