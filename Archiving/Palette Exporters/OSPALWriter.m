//
//  OSPALWriter.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "OSPALWriter.h"

#import "PXPalette.h"

#pragma pack(1)

typedef struct
{
	uint32_t signature;
	uint32_t fileLength;
	uint32_t riffType;
} OSPALHeader;

@implementation OSPALWriter

- (id)init
{
	[NSException raise:@"SingletonError" format:@"OSPALWriter is a singleton; use sharedPALWriter to access the shared instance."];
	return nil;
}

- (id)_init
{
	self = [super init];
	return self;
}

+ (id)sharedPALWriter
{
	static OSPALWriter *sharedPALWriter = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedPALWriter = [[OSPALWriter alloc] _init];
	});
	
	return sharedPALWriter;
}

- (NSData *)palDataForPalette:(PXPalette *)palette
{
	NSMutableData *data = [NSMutableData data];
	NSUInteger colorCount = [palette colorCount];
	NSUInteger length = 24 + (4 * colorCount);
	
	// Construct the header
	OSPALHeader header;
	header.signature = CFSwapInt32HostToLittle('FFIR'); // Magic number for PAL
	header.fileLength = CFSwapInt32HostToLittle( (int) length - 8); // Size of the file minus this long and the previous one.
	header.riffType = CFSwapInt32HostToLittle(' LAP'); // Always the same for palettes
	[data appendBytes:&header length:sizeof(OSPALHeader)];
	
	// Construct the RIFF chunk
	unsigned long riffSignature = CFSwapInt32HostToLittle('atad');
	[data appendBytes:&riffSignature length:4];
	unsigned long chunkSize = CFSwapInt32HostToLittle( (int) length - 20);
	[data appendBytes:&chunkSize length:4];
	
	// The first data long is in two shorts: a palette version and the number of colors in the palette.
	char riffHeader[4];
	riffHeader[0] = 0;
	riffHeader[1] = 3;
	riffHeader[2] = colorCount % 256;
	riffHeader[3] = colorCount / 256;
	[data appendBytes:riffHeader length:4];
	
	// Write the color data.
	for (NSColor *color in palette)
	{
		char colorData[4];
		colorData[0] = (int) roundf([color redComponent] * 255);
		colorData[1] = (int) roundf([color greenComponent] * 255);
		colorData[2] = (int) roundf([color blueComponent] * 255);
		colorData[3] = 0;
		[data appendBytes:colorData length:4];
	}
	
	return data;
}

#pragma pack()

@end
