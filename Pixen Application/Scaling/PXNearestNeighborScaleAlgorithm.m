//
//  PXNearestNeighborScaleAlgorithm.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXNearestNeighborScaleAlgorithm.h"

#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"

@implementation PXNearestNeighborScaleAlgorithm

- (NSString *)name
{
	return @"Nearest Neighbor";
}

- (NSString *)algorithmInfo
{
	return NSLocalizedString(@"NEAREST_NEIGHBOR_INFO", "Nearest Neighbor Info Here");
}

- (BOOL)canScaleCanvas:canvas toSize:(NSSize)size
{
	if (canvas == nil || size.width == 0 || size.height == 0) {
		return NO;
	}
	return YES;
}

- (void)scaleCanvas:canvas toSize:(NSSize)size
{
	if (!canvas)
		return;
	
	PXLayer *layerCopy;
	NSPoint currentPoint;
	int x, y;
	float xScale = size.width / [canvas size].width;
	float yScale = size.height / [canvas size].height;
	
	[canvas beginColorUpdates];
	
	for (PXLayer *layer in [canvas layers])
	{
		layerCopy = [layer copy];
		[layer setSize:size];
		
		for (x=0; x<size.width; x++) {
			for (y=0; y<size.height; y++) {
				currentPoint = NSMakePoint((int)(x/xScale),(int)(y/yScale));
				[canvas setColor:[layerCopy colorAtPoint:currentPoint]
						 atPoint:NSMakePoint(x, y)
						 onLayer:layer];
			}
		}
	}
	
	[canvas changed];
	[canvas endColorUpdates];
}

@end
