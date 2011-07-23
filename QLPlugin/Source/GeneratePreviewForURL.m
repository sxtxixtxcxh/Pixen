#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <Foundation/Foundation.h>
#import <AppKit/NSGraphicsContext.h>

#import "PXCanvas.h"

OSStatus GeneratePreviewForURL (void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration (void* thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL (void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	PXCanvas *canvas = [NSKeyedUnarchiver unarchiveObjectWithFile:[ (NSURL *) url path]];
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:[canvas size].width], kQLPreviewPropertyWidthKey,
						  [NSNumber numberWithInt:[canvas size].height], kQLPreviewPropertyHeightKey, nil];
	
	NSSize canvasSize = [canvas size];
	CGContextRef ctx = QLPreviewRequestCreateContext(preview, CGSizeMake(canvasSize.width, canvasSize.height), 1, (CFDictionaryRef) dict);
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO]];
	
	[canvas draw];
	
	QLPreviewRequestFlushContext(preview, ctx);
	
	[pool release];
	
    return noErr;
}

void CancelPreviewGeneration (void* thisInterface, QLPreviewRequestRef preview)
{
	// implement only if supported
}
