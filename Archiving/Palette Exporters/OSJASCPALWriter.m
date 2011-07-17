//
//  OSJASCPALWriter.m
//  PALExport
//
//  Created by Andy Matuschak on 8/16/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "OSJASCPALWriter.h"


@implementation OSJASCPALWriter

- init
{
	[NSException raise:@"SingletonError" format:@"OSJASCPALWriter is a singleton; use sharedJASCPALWriter to access the shared instance."];
	return nil;
}

- (id)_init
{
	self = [super init];
	return self;
}

+ (id)sharedJASCPALWriter
{
	static OSJASCPALWriter *sharedJASCPALWriter = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedJASCPALWriter = [[OSJASCPALWriter alloc] _init];
	});
	
	return sharedJASCPALWriter;
}

- (NSData *)palDataForPalette:(PXPalette *)palette
{
	NSMutableString *string = [NSMutableString string];
	[string appendString:@"JASC-PAL\n0100\n"];
	
	NSUInteger colorCount = PXPalette_colorCount(palette);
	[string appendFormat:@"%d\n", colorCount];
	
	NSUInteger i;
	for (i = 0; i < colorCount; i++)
	{
		NSColor *color = [palette->colors[i].color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		[string appendFormat:@"%d %d %d\n", (int) roundf([color redComponent] * 255), (int) roundf([color greenComponent] * 255), (int) roundf([color blueComponent] * 255)];
	}
	
	return [string dataUsingEncoding:NSASCIIStringEncoding];
}

@end
