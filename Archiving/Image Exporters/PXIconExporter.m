//
//  PXIconExporter.m
//  Pixen
//
//  Created by Andy Matuschak on 6/16/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXIconExporter.h"
#import "PXCanvas.h"
#import "PXCanvas_ImportingExporting.h"

typedef uint8_t byte;
typedef uint16_t word;
typedef uint32_t dword;

#pragma pack(1)

typedef struct
{
    byte        bWidth;          // Width, in pixels, of the image
    byte        bHeight;         // Height, in pixels, of the image
    byte        bColorCount;     // Number of colors in image (0 if >=8bpp)
    byte        bReserved;       // Reserved ( must be 0)
    word        wPlanes;         // Color Planes
    word        wBitCount;       // Bits per pixel
    dword       dwBytesInRes;    // How many bytes in this resource?
    dword       dwImageOffset;   // Where in the file is this image?
} ICONDIRENTRY, *LPICONDIRENTRY;

typedef struct ICONDIR
{
    word          idReserved;   // Reserved (must be 0)
    word          idType;       // Resource Type (1 for icons)
    word          idCount;      // How many images?
	
    // we're only using one resolution, so there's only one entry.
	ICONDIRENTRY idEntry;
} ICONHEADER;

typedef struct tagBITMAPINFOHEADER
{
	dword   biSize;
	dword    biWidth;
	dword    biHeight;
	word    biPlanes;
	word    biBitCount;
	dword   biCompression;
	dword   biSizeImage;
	dword    biXPelsPerMeter;
	dword    biYPelsPerMeter;
	dword   biClrUsed;
	dword   biClrImportant;
} BITMAPINFOHEADER;

typedef struct tagRGBQUAD
{
	byte    rgbBlue;
	byte    rgbGreen;
	byte    rgbRed;
	byte    rgbReserved;
} RGBQUAD;

typedef struct
{
	BITMAPINFOHEADER   icHeader;      // DIB header
	
	// writing these separately due to sizing issues
	// RGBQUAD         icColors[1];   // Color table
	// byte            icXOR[1];      // DIB bits for XOR mask
	// byte            icAND[1];      // DIB bits for AND mask
} ICONIMAGE, *LPICONIMAGE;

@interface PXIconExporter ()

- (void)writeIconFileHeader:(NSMutableData *)data withCanvas:(PXCanvas *)canvas;
- (void)writeImageData:(NSMutableData *)data withCanvas:(PXCanvas *)canvas;
- (void)writeImage:(NSMutableData *)data withCanvas:(PXCanvas *)canvas;

@end

#define IMAGE_SIZE (canvasSize.width * canvasSize.height * 4)

@implementation PXIconExporter

- (NSData *)iconDataForCanvas:(PXCanvas *)aCanvas
{
	if ([aCanvas size].width > 256 || [aCanvas size].height > 256)
	{
		[[NSAlert alertWithMessageText:NSLocalizedString(@"Can't save image", @"Can't save image")
						 defaultButton:NSLocalizedString(@"OK", @"OK")
					   alternateButton:nil
						   otherButton:nil
			 informativeTextWithFormat:NSLocalizedString(@"The Windows icon format doesn't support images with width or height above 256", @"The Windows icon format doesn't support images with width or height above 256")] runModal];
		return nil;
	}
	
	NSMutableData *data = [[NSMutableData alloc] init];
	
	[self writeIconFileHeader:data withCanvas:aCanvas];
	[self writeImage:data withCanvas:aCanvas];
	
	return data;
}

- (void)writeIconFileHeader:(NSMutableData *)data withCanvas:(PXCanvas *)canvas
{
	ICONHEADER iconHeader;
	iconHeader.idReserved = CFSwapInt16HostToLittle(0); // reserved is always 0
	iconHeader.idType = CFSwapInt16HostToLittle(1); // icons are 1
	iconHeader.idCount = CFSwapInt16HostToLittle(1); // we're only gonna deal with one resolution
	
	ICONDIRENTRY dirEntry;
	NSSize canvasSize = [canvas size];
	dirEntry.bWidth = canvasSize.width;
	dirEntry.bHeight = canvasSize.height;
	dirEntry.bColorCount = 0; // not dealing with color tables
	dirEntry.bReserved = 0; // this is always 0
	dirEntry.wPlanes = CFSwapInt16HostToLittle(1); // I think this is supposed to always be 1 for icons
	dirEntry.wBitCount = CFSwapInt16HostToLittle(32);
	dirEntry.dwBytesInRes = CFSwapInt32HostToLittle(sizeof(BITMAPINFOHEADER) + IMAGE_SIZE);
	dirEntry.dwImageOffset = CFSwapInt32HostToLittle(sizeof(ICONHEADER));
	iconHeader.idEntry = dirEntry;
	
	[data appendBytes:&iconHeader length:sizeof(ICONHEADER)];
}

- (void)writeImageData:(NSMutableData *)data withCanvas:(PXCanvas *)canvas
{
	// write color data
	int i, j;
	NSSize canvasSize = [canvas size];
	for (j = 0; j < canvasSize.height; j++)
	{
		int bytesWritten = 0;
		for (i = 0; i < canvasSize.width; i++)
		{
			NSColor *color = [NSReadPixel(NSMakePoint(i, j)) colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
			byte colors[4];
			colors[3] = (int) roundf([color alphaComponent] * 255);
			colors[2] = (int) roundf([color redComponent] * 255);
			colors[1] = (int) roundf([color greenComponent] * 255);
			colors[0] = (int) roundf([color blueComponent] * 255);
			[data appendBytes:colors length:4 * sizeof(byte)];
			bytesWritten += 4;
		}
	}	
}

- (void)writeImage:(NSMutableData *)data withCanvas:(PXCanvas *)canvas
{
	// set up bitmap info header
	BITMAPINFOHEADER bitmapHeader;
	memset(&bitmapHeader, 0, sizeof(BITMAPINFOHEADER));
	NSSize canvasSize = [canvas size];
	// note all the endian swaps; these are important
	bitmapHeader.biSize = CFSwapInt32HostToLittle(sizeof(BITMAPINFOHEADER));
	bitmapHeader.biWidth = CFSwapInt32HostToLittle((uint32_t)canvasSize.width);
	bitmapHeader.biHeight = CFSwapInt32HostToLittle((uint32_t)canvasSize.height*2); // height is doubled because it covers the mask, too
	bitmapHeader.biPlanes = CFSwapInt16HostToLittle(1); // I think this is always supposed to be 1 for icons
	bitmapHeader.biBitCount = CFSwapInt16HostToLittle(32); // alpha channel is included
	bitmapHeader.biSizeImage = CFSwapInt32HostToLittle(IMAGE_SIZE);
	[data appendBytes:&bitmapHeader length:sizeof(BITMAPINFOHEADER)];
	
	// get merged image
	NSImage *mergedImage = [canvas exportImage];
	[mergedImage lockFocus];
	
	[self writeImageData:data withCanvas:canvas];
	
	[mergedImage unlockFocus];
}

#pragma pack()

@end
