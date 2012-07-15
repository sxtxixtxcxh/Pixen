//
//  PXGifImporter.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXGifImporter.h"

@implementation PXGifImporter

+ (BOOL)fileAtURLIsAnimated:(NSURL *)url
{
	NSImage *tempImage = [[NSImage alloc] initWithContentsOfURL:url];
	int frameCount = [[[[tempImage representations] objectAtIndex:0] valueForProperty:NSImageFrameCount] intValue];
	return (frameCount > 1);
}

@end
