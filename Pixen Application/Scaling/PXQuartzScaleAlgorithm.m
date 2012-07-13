//
//  PXQuartzScaleAlgorithm.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXQuartzScaleAlgorithm.h"

#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"

@implementation PXQuartzScaleAlgorithm

- (NSString *)name
{
	return @"Quartz";
}

- (NSString *)algorithmInfo
{
	return @"This algorithm uses Quartz's built-in scaling behavior.";
}

- (BOOL)canScaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size
{
	if (canvas == nil || size.width == 0 || size.height == 0) 
		return NO;
	
	return YES;
}

- (void)scaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size
{
	if (!canvas) 
		return;
	
	for (PXLayer *layer in [canvas layers])
	{
		int oldOpacity = [layer opacity];
		[layer setOpacity:100];
		
		NSBitmapImageRep *layerImageRep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																				   pixelsWide:size.width
																				   pixelsHigh:size.height
																				bitsPerSample:8
																			  samplesPerPixel:4
																					 hasAlpha:YES
																					 isPlanar:NO
																			   colorSpaceName:NSCalibratedRGBColorSpace
																				  bytesPerRow:size.width * 4
																				 bitsPerPixel:32] autorelease];
		
		[NSGraphicsContext saveGraphicsState];
		[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:layerImageRep]];
		
		[layer drawInRect:(NSRect){NSZeroPoint, size} fromRect:(NSRect){NSZeroPoint, [layer size]} operation:NSCompositeCopy fraction:1];
		
		[NSGraphicsContext restoreGraphicsState];
		
		[layer setOpacity:oldOpacity];
		[layer setSize:size];
		
		[canvas applyImageRep:layerImageRep toLayer:layer];
	}
	
	[canvas changed];
}

@end