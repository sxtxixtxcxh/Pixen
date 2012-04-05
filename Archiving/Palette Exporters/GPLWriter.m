//
//  GPLWriter.m
//  Pixen
//
//  Created by Collin Sanford on 4/5/12.
//  Copyright 2012 Collin Sanford. All rights reserved.
//

#import "GPLWriter.h"


@implementation GPLWriter

- (id)init
{
	[NSException raise:@"SingletonError" format:@"GPLWriter is a singleton; use sharedGPLWriter to access the shared instance."];
	return nil;
}

- (id)_init
{
	self = [super init];
	return self;
}

+ (id)sharedGPLWriter
{
	static GPLWriter *sharedGPLWriter = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedGPLWriter = [[GPLWriter alloc] _init];
	});
	
	return sharedGPLWriter;
}

- (NSData *)palDataForPalette:(PXPalette *)palette
{
	NSMutableString *string = [NSMutableString string];
	[string appendString:@"GIMP Palette\n"];
    [string appendString:@"Name: "];
    [string appendString:palette.name];
    [string appendString:@"\nColumns: 16\n#\n"];
	
    __block int i = 1;
	[palette enumerateWithBlock:^(PXColor color) {
		[string appendFormat:@"%d %d %d Color %d\n", color.r, color.g, color.b, i];
        i++;
	}];
	
	return [string dataUsingEncoding:NSASCIIStringEncoding];
}

@end
