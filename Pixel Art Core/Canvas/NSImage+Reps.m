//
//  NSImage+Reps.m
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "NSImage+Reps.h"

@implementation NSImage (Reps)

+ (NSImage *)imageWithBitmapImageRep:(NSBitmapImageRep *)rep {
	NSImage *image = [[NSImage alloc] initWithSize:[rep size]];
	[image addRepresentation:rep];
	
	return [image autorelease];
}

@end
