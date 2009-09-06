//
//  PXCanvas_ImportingExporting.m
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXCanvas_ImportingExporting.h"
#import "PXCanvas_Layers.h"
#import "PXBitmapExporter.h"
#import "PXPSDHandler.h"
#import "PXLayer.h"
#ifndef __COCOA__
#include <math.h>
#import "PXNotifications.h"
#import "PXDefaults.h"
#endif

@implementation PXCanvas(ImportingExporting)

+ canvasWithContentsOfFile:(NSString *)aFile
{
	return [[[self alloc] initWithContentsOfFile:aFile] autorelease];
}

-(id) initWithContentsOfFile:(NSString* ) aFile
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


- imageDataWithType:(NSBitmapImageFileType)storageType
		 properties:(NSDictionary *)properties
{
	NSBitmapImageRep *rep;
	NSRect frame = NSMakeRect(0, 0, [self size].width, [self size].height);
	// We use a white background color for jpegs because of a bug in 10.3
	id outputImage = ((storageType == NSJPEGFileType) ? [self exportImageWithBackgroundColor:[NSColor whiteColor]] : [self displayImage]);
	[outputImage lockFocus];
	rep = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:frame] autorelease];
	[outputImage unlockFocus];
	unsigned char *bitmapData = [rep bitmapData];
	rep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&bitmapData pixelsWide:[self size].width pixelsHigh:[self size].height bitsPerSample:8 samplesPerPixel:[rep samplesPerPixel] hasAlpha:[rep hasAlpha] isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:[rep bytesPerRow] bitsPerPixel:[rep bitsPerPixel]] autorelease];
	
	// And now, we interrupt our regularly scheduled codegram for a hack: remove color profile info from the rep because we don't handle it on loading.
	[rep setProperty:NSImageColorSyncProfileData withValue:nil];
	
	if (storageType == NSBMPFileType)
	{
#ifdef __COCOA__
		if (PXPalette_colorCount([self palette]) <= 256)
		{
			return [PXBitmapExporter indexedBitmapDataForCanvas:self];
		}
		else
		{
			return [PXBitmapExporter BMPDataForImage:outputImage];
		}
#else
#warning GNUstep / COCOA implement that without Quicktime 
		return nil;
#endif
	}
	else
	{
		return [rep representationUsingType:storageType properties:properties];
	}	
}

- PICTData
{
	id outputImage = [self exportImage];
#ifdef __COCOA__
	return [PXBitmapExporter PICTDataForImage:outputImage];
#else
#warning GNUstep/Cocoa implement that without Quicktime
	return nil;
#endif
}

- (void)replaceActiveLayerWithImage:(NSImage *)anImage
{
	NSImageRep *firstRep = [[anImage representations] objectAtIndex:0];
	//some PNGs have ... fractional sizes.  So I put in this ceilfing.
	NSSize newSize = NSMakeSize([firstRep pixelsWide], [firstRep pixelsHigh]);
	id enumerator = [layers objectEnumerator];
	id current;
	while(current = [enumerator nextObject])
	{
		[current setSize:newSize withOrigin:NSZeroPoint backgroundColor:[NSColor clearColor]];
	}
	free(selectionMask);
	selectionMask = calloc(newSize.width * newSize.height, sizeof(BOOL));
	selectedRect = NSZeroRect;
	// if we're using a gif, let's set up the color table in the originally specified order
	NSData *table = nil;
	if ([firstRep respondsToSelector:@selector(valueForProperty:)]) {
		table = [(NSBitmapImageRep *)firstRep valueForProperty:NSImageRGBColorTable];
	}
	if (table)
	{
		int colors = [table length] / 3;
		int i;
		const unsigned char *bytes = [table bytes];
		BOOL checkForDuplicates = (PXPalette_colorCount(palette) > 0);
		for (i = 0; i < colors; i++)
		{
			float red = bytes[i*3] / 255.0;
			float green = bytes[i*3 + 1] / 255.0;
			float blue = bytes[i*3 + 2] / 255.0;
			if (checkForDuplicates)
				PXPalette_addColorWithoutDuplicating(palette, [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1]);
			else
				PXPalette_addColor(palette, [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1]);
		}
	}
	if([layers count] == 0)
	{
		[layers addObject:[[[PXLayer alloc] initWithName:@"Main Layer" size:newSize] autorelease]];
		[[layers lastObject] setCanvas:self];
		[self activateLayer:[layers lastObject]];
	}
	[activeLayer applyImage:anImage];
	[self updatePreviewSize];
	[self layersChanged];
}

- initWithImage:(NSImage *)anImage type:(NSString *)type
{
	[self initWithoutBackgroundColor];
	[self replaceActiveLayerWithImage:anImage];
	return self;
}

- initWithImage:(NSImage *)anImage
{
	return [self initWithImage:anImage type:PNGFileType];
}

- initWithPSDData:(NSData *)data
{
#ifdef __COCOA__
	[self init];
	id images = [PXPSDHandler imagesForPSDData:data];
	[self setSize:[[images objectAtIndex:0] size]];
	id enumerator = [images objectEnumerator], current;
	while (current = [enumerator nextObject])
	{
		id layer = [[[PXLayer alloc] initWithName:NSLocalizedString(@"Imported Layer", @"Imported Layer") size:[current size]] autorelease];
		[self addLayer:layer];
		[layer applyImage:current];
	}
	[[self undoManager] removeAllActions];
	return self;
#else
#warning GNUstep implement that without QUICKTIME
	return nil;
#endif
}

- (NSImage *)displayImage
{
	NSImage *imageCopy = [[NSImage alloc] initWithSize:[self size]];
	[imageCopy lockFocus];
	NSEnumerator *layerEnumerator = [layers reverseObjectEnumerator];
	PXLayer *layer;
	while (layer = [layerEnumerator nextObject])
	{
		[[layer displayImage] compositeToPoint:canvasRect.origin fromRect:canvasRect operation:NSCompositeDestinationOver fraction:[layer opacity] / 100.0f];
	}
	[imageCopy unlockFocus];
	return [imageCopy autorelease];	
}

- (NSImage *)exportImageWithBackgroundColor:(NSColor *)color
{
	NSImage *imageCopy = [[NSImage alloc] initWithSize:[self size]];
	[imageCopy lockFocus];
	[[[imageCopy representations] objectAtIndex:0] setColorSpaceName:NSCalibratedRGBColorSpace]; // Tell the image to write out calibrated-ly; let's avoid any conversion.
	NSEnumerator *layerEnumerator = [layers reverseObjectEnumerator];
	PXLayer *layer;
	while (layer = [layerEnumerator nextObject])
	{
		[[layer exportImage] compositeToPoint:canvasRect.origin fromRect:canvasRect operation:NSCompositeDestinationOver fraction:[layer opacity] / 100.0f];
	}
	// We fill the color (if necessary) after because of the backwards order in which we're doing this
	if (color)
	{
		[color set];
		NSRectFillUsingOperation(canvasRect, NSCompositeDestinationOver);
	}
	[imageCopy unlockFocus];
	return [imageCopy autorelease];	
}

- (NSImage *)exportImage
{
	return [self exportImageWithBackgroundColor:nil];
}

@end
