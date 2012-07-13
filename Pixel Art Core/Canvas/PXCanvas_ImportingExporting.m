//
//  PXCanvas_ImportingExporting.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvas_ImportingExporting.h"

#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"

@implementation PXCanvas(ImportingExporting)

+ (id)canvasWithContentsOfFile:(NSString *)aFile
{
	return [[[self alloc] initWithContentsOfFile:aFile] autorelease];
}

- (id)initWithContentsOfFile:(NSString *)aFile
{
	if([[aFile pathExtension] isEqualToString:PXISuffix])
	{
		[self release];
		return self = [[NSKeyedUnarchiver unarchiveObjectWithFile:aFile] retain];
	}
	else
	{
		return [self initWithImage:[[[NSImage alloc] initWithContentsOfFile:aFile] autorelease]];
	}
	[self release];
	return self = nil;
}

- (NSData *)imageDataWithType:(NSBitmapImageFileType)storageType
				   properties:(NSDictionary *)properties
{
	return [[self imageRep] representationUsingType:storageType properties:properties];
}

- (void)replaceActiveLayerWithImage:(NSImage *)anImage
{
	if (![[[anImage representations] objectAtIndex:0] isKindOfClass:[NSBitmapImageRep class]]) {
		@throw [NSException exceptionWithName:NSGenericException reason:@"Not a bitmap file" userInfo:nil];
		return;
	}
	
	NSBitmapImageRep *firstRep = [[anImage representations] objectAtIndex:0];
	NSSize newSize = NSMakeSize((int)[firstRep pixelsWide], (int)[firstRep pixelsHigh]);
	
	for (PXLayer *currentLayer in layers) {
		[currentLayer setSize:newSize withOrigin:NSZeroPoint backgroundColor:PXGetClearColor()];
	}
	
	free(selectionMask);
	selectionMask = calloc(newSize.width * newSize.height, sizeof(BOOL));
	selectedRect = NSZeroRect;
	if([layers count] == 0)
	{
		[layers addObject:[[[PXLayer alloc] initWithName:@"Main Layer" size:newSize] autorelease]];
		[[layers lastObject] setCanvas:self];
		[self activateLayer:[layers lastObject]];
	}
	[self applyImageRep:firstRep toLayer:activeLayer];
	[self updatePreviewSize];
	[self layersChanged];
}

- (id)initWithImage:(NSImage *)anImage
{
	self = [self init];
	[self replaceActiveLayerWithImage:anImage];
	return self;
}

- (NSBitmapImageRep *)imageRep
{
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																		 pixelsWide:[self size].width
																		 pixelsHigh:[self size].height
																	  bitsPerSample:8
																	samplesPerPixel:4
																		   hasAlpha:YES
																		   isPlanar:NO
																	 colorSpaceName:NSCalibratedRGBColorSpace
																		bytesPerRow:[self size].width * 4
																	   bitsPerPixel:32];
	
	NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep:imageRep];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:ctx];
	
	NSRect r = NSMakeRect(0, 0, [self size].width, [self size].height);
	
	[[NSColor clearColor] set];
	NSRectFill(r);
	
	for (PXLayer *layer in layers)
	{
		if ([layer visible] && [layer opacity] > 0)
		{
			[[layer imageRep] drawInRect:r
								fromRect:r
							   operation:NSCompositeSourceOver
								fraction:[layer opacity] / 100.0f
						  respectFlipped:NO
								   hints:nil];
		}
	}
	
	[NSGraphicsContext restoreGraphicsState];
	
	// And now, we interrupt our regularly scheduled codegram for a hack: remove color profile info from the rep because we don't handle it on loading.
	[imageRep setProperty:NSImageColorSyncProfileData withValue:nil];
	
	return [imageRep autorelease];
}

@end
