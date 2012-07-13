//
//  OSJASCPALWriter.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "OSJASCPALWriter.h"

@implementation OSJASCPALWriter

- (id)init
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
	
	NSUInteger colorCount = [palette colorCount];
	[string appendFormat:@"%ld\n", colorCount];
	
	[palette enumerateWithBlock:^(PXColor color) {
		[string appendFormat:@"%d %d %d\n", color.r, color.g, color.b];
	}];
	
	return [string dataUsingEncoding:NSASCIIStringEncoding];
}

@end
