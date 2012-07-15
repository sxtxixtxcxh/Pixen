//
//  PXScale2xScaleAlgorithm.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXScale2xScaleAlgorithm.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"

@implementation PXScale2xScaleAlgorithm

- (NSString *)name
{
	return @"Scale2x";
}

- (NSString *)algorithmInfo
{
	return NSLocalizedString(@"SCALE2X_INFO", @"Scale2x Info Here");
}

- (BOOL)canScaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size
{
	if (canvas == nil || size.width < 1 || size.height < 1) {
		return NO;
	}
	double widthLog = log2(size.width / [canvas size].width);
	double heightLog = log2(size.height / [canvas size].height);
	if (fabs(floor(widthLog) - widthLog) > .001 || fabs(floor(heightLog) - heightLog) > .001 || fabs(widthLog - heightLog) > .001) {
		return NO;
	}
	return YES;
}

- (void)scaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size
{
	if (! canvas ) {
		return;
	}
	PXLayer *layerCopy;
	int x, y;
	PXColor /* *A,*/ B, /* *C,*/ D, E, F, /* *G,*/ H, /* *I,*/ E0, E1, E2, E3;
	int xScale = size.width / [canvas size].width;
	int yScale = size.height / [canvas size].height;
	int layerWidth, layerHeight;
	layerWidth = [canvas size].width;
	layerHeight = [canvas size].height;
	
	[canvas beginColorUpdates];
	
	while (xScale > 1 && yScale > 1) {
		layerWidth = layerWidth << 1;
		layerHeight = layerHeight << 1;
		
		for (PXLayer *layer in [canvas layers])
		{
			@autoreleasepool {
				layerCopy = [layer copy];
				[layer setSize:NSMakeSize(layerWidth, layerHeight)];
				for (x=0; x<[canvas size].width; x++) {
					for (y=0; y<[canvas size].height; y++) {
						// A B C
						// D E F
						// G H I
						
						// A = [layerCopy colorAtPoint:NSMakePoint(x - 1, y - 1)];
						B = [layerCopy colorAtPoint:NSMakePoint(x    , y - 1)];
						// C = [layerCopy colorAtPoint:NSMakePoint(x + 1, y - 1)];
						D = [layerCopy colorAtPoint:NSMakePoint(x - 1, y)];
						E = [layerCopy colorAtPoint:NSMakePoint(x    , y)];
						F = [layerCopy colorAtPoint:NSMakePoint(x + 1, y)];
						// G = [layerCopy colorAtPoint:NSMakePoint(x - 1, y + 1)];
						H = [layerCopy colorAtPoint:NSMakePoint(x    , y + 1)];
						// I = [layerCopy colorAtPoint:NSMakePoint(x + 1, y + 1)];
						
						if (!PXColorEqualsColor(B, H) && !PXColorEqualsColor(D, F)) {
							E0 = PXColorEqualsColor(D, B) ? D : E;
							E1 = PXColorEqualsColor(B, F) ? F : E;
							E2 = PXColorEqualsColor(D, H) ? D : E;
							E3 = PXColorEqualsColor(H, F) ? F : E;
						} else {
							E0 = E;
							E1 = E;
							E2 = E;
							E3 = E;
						}
						
						[canvas setColor:E0 atPoint:NSMakePoint(x*2, y*2) onLayer:layer];
						[canvas setColor:E1 atPoint:NSMakePoint(x*2 + 1, y*2) onLayer:layer];
						[canvas setColor:E2 atPoint:NSMakePoint(x*2, y*2 + 1) onLayer:layer];
						[canvas setColor:E3 atPoint:NSMakePoint(x*2 + 1, y*2 + 1) onLayer:layer];
					}
				}
			}
		}
		xScale = xScale >> 1;
		yScale = yScale >> 1;
	}
	
	[canvas changed];
	[canvas endColorUpdates];
}

@end
