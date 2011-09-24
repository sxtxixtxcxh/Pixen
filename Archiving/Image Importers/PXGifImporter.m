//
//  PXGifImporter.m
//  Pixen
//
//  Created by Andy Matuschak on Fri Jul 16 2004.
//  Copyright (c) 2004 Pixen. All rights reserved.
//

#import "PXGifImporter.h"

@implementation PXGifImporter

+ (BOOL)fileAtURLIsAnimated:(NSURL *)url
{
	NSImage *tempImage = [[[NSImage alloc] initWithContentsOfURL:url] autorelease];
	int frameCount = [[[[tempImage representations] objectAtIndex:0] valueForProperty:NSImageFrameCount] intValue];
	return (frameCount > 1);
}

@end
