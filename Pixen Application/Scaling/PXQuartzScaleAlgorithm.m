//
//  PXQuartzScaleAlgorithm.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
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
		NSImage *newLayerImage = [[[NSImage alloc] initWithSize:size] autorelease];
		int oldOpacity = [layer opacity];
		[layer setOpacity:100];
		[newLayerImage lockFocus];
		[layer drawInRect:(NSRect){NSZeroPoint, size} fromRect:(NSRect){NSZeroPoint, [layer size]} operation:NSCompositeCopy fraction:1];
		[newLayerImage unlockFocus];
		[layer setOpacity:oldOpacity];
		[layer setSize:size];
		[canvas applyImage:newLayerImage toLayer:layer];
	}
	
	[canvas layersChanged];
	[canvas changed];
}

@end