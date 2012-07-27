#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <Foundation/Foundation.h>
#import <AppKit/NSGraphicsContext.h>

#import "PXCanvas.h"

OSStatus GenerateThumbnailForURL (void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration (void* thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL (void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
	@autoreleasepool {
	
		PXCanvas *canvas = [NSKeyedUnarchiver unarchiveObjectWithFile:[ (__bridge NSURL *) url path]];
		
		CGContextRef ctx = QLThumbnailRequestCreateContext(thumbnail, NSSizeToCGSize([canvas size]), 1, NULL);
		[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO]];
		
		[canvas draw];
		
		QLThumbnailRequestFlushContext(thumbnail, ctx);
		
		
    return noErr;
    }
}

void CancelThumbnailGeneration (void* thisInterface, QLThumbnailRequestRef thumbnail)
{
	// implement only if supported
}
