//
//  PXCanvas_Modifying.m
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXCanvas_Modifying.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXLayer.h"
#import "PXCanvas_Selection.h"
#import "gif_lib.h"
#ifndef __COCOA__
#include <math.h>
#import "PXNotifications.h"
#import "PXDefaults.h"
#endif
#import "NSString_DegreeString.h"


@implementation PXCanvas(Modifying)

- (BOOL)wraps
{
	return wraps;
}

- (void)setWraps:(BOOL)newWraps suppressRedraw:(BOOL)suppress
{
	wraps = newWraps;
	if (!suppress)
		[self changed];	
}

- (void)setWraps:(BOOL)newWraps
{
	[self setWraps:newWraps suppressRedraw:NO];
}

- (BOOL)containsPoint:(NSPoint)aPoint
{
	return wraps || NSPointInRect(aPoint, canvasRect);
}

- (NSPoint)correct:(NSPoint)aPoint
{
	if(!wraps) { return aPoint; }
	NSPoint corrected = aPoint;
	while(corrected.x < 0)
	{
		corrected.x += [self size].width;
	}
	while(corrected.y < 0)
	{
		corrected.y += [self size].height;
	}
	corrected.x = (int)(corrected.x) % (int)([self size].width);
	corrected.y = (int)(corrected.y) % (int)([self size].height);
	return corrected;	
}

- (void)setColorIndex:(unsigned int)index atPoint:(NSPoint)aPoint
{
	if(![self containsPoint:aPoint]) { return; }
	[activeLayer setColorIndex:index atPoint:[self correct:aPoint]];
}

- (void)setColorIndex:(unsigned int)index atIndex:(unsigned int)loc ofLayer:(PXLayer *)layer
{
	[[undoManager prepareWithInvocationTarget:self] setColorIndex:[layer colorIndexAtIndex:loc] atIndex:loc ofLayer:layer];
	[layer setColorIndex:index atIndex:loc];
	int x = loc % (int)[self size].width;
	int y = [self size].height - ((loc - x)/[self size].width) - 1;
	[self changedInRect:NSMakeRect( x, y, 1, 1)];
}

- (void)setColorIndex:(unsigned int)index atIndex:(unsigned int)loc
{
	[self setColorIndex:index atIndex:loc ofLayer:activeLayer];
}

- (void)setColorIndex:(unsigned int)index atIndices:(NSArray *)indices updateIn:(NSRect)bounds onLayer:(PXLayer *)layer simpleUndo:(BOOL)assumeIndicesAreTheSameColor
{
	if([indices count] == 0) { return; }
	[self beginUndoGrouping]; {
		if(assumeIndicesAreTheSameColor)
		{
			unsigned oldColorIndex = [layer colorIndexAtIndex:[[indices objectAtIndex:0] intValue]];
			[[undoManager prepareWithInvocationTarget:self] setColorIndex:oldColorIndex atIndices:indices updateIn:bounds onLayer:layer simpleUndo:assumeIndicesAreTheSameColor];
		}
		[self beginOptimizedSetting]; {
			id enumerator = [indices objectEnumerator], current;
			while(current = [enumerator nextObject])
			{
				int val = [current intValue];
				if(assumeIndicesAreTheSameColor)
				{
					[layer setColorIndex:index atIndex:val];
				}
				else
				{
					[self setColorIndex:index atIndex:val ofLayer:layer];
				}
			}
		} [self endOptimizedSetting];
	//
	} [self endUndoGrouping:assumeIndicesAreTheSameColor ? NSLocalizedString(@"Fill", @"Fill") : NSLocalizedString(@"Drawing", @"Drawing")];
	[self changedInRect:bounds]; 		
}

- (void)setColorIndex:(unsigned int)index atIndices:(NSArray *)indices updateIn:(NSRect)bounds simpleUndo:(BOOL)assumeIndicesAreTheSameColor
{
	[self setColorIndex:index atIndices:indices updateIn:bounds onLayer:activeLayer simpleUndo:assumeIndicesAreTheSameColor];
}

- (NSColor*) colorAtPoint:(NSPoint)aPoint
{
	if( ! [self containsPoint:aPoint] ) 
		return nil; 
	
	return [activeLayer colorAtPoint:aPoint];
}

- (unsigned int) colorIndexAtPoint:(NSPoint)aPoint
{
	if( ! [self containsPoint:aPoint] ) 
		return 0;
	
	return [activeLayer colorIndexAtPoint:aPoint];
}

- (void)setColor:(NSColor *)aColor atPoint:(NSPoint)aPoint
{
	if(![self containsPoint:aPoint]) 
		return;
	
	[activeLayer setColor:aColor atPoint:[self correct:aPoint]];
}

- (void)setColor:(NSColor *) aColor atPoints:(NSArray *)points
{
	if([self hasSelection])
	{
		NSEnumerator *enumerator = [points objectEnumerator];
		NSString *current;
		
		while ( ( current = [enumerator nextObject] ) ) 
		{
			NSPoint aPoint = NSPointFromString(current);
			if (!selectionMask[(int)(aPoint.x + (aPoint.y * [self size].width))]) 
			{
				return; 
			}
		}
	}
	int i;
	NSPoint point;
	//violates law of demeter, but is needed for the optimized setting.
	PXImage_beginOptimizedSetting([activeLayer image]);
	for (i=0; i<[points count]; i++) {
		point = [self correct:[[points objectAtIndex:i] pointValue]];
		PXImage_setColorAtXY([activeLayer image], (int)(point.x), (int)(point.y), aColor);		
	}
	PXImage_endOptimizedSetting([activeLayer image]);	
}

- (void)beginOptimizedSetting
{
	[activeLayer beginOptimizedSetting];
}

- (void)endOptimizedSetting
{
	[activeLayer endOptimizedSetting];
}

- (void)rotateByDegrees:(int)degrees
{
	[self beginUndoGrouping]; {
		NSEnumerator *enumerator = [layers objectEnumerator];
		PXLayer *current;
		while (current = [enumerator nextObject])
		{
			[self rotateLayer:current byDegrees:degrees];
		}
	} [self endUndoGrouping:[NSString stringWithFormat:NSLocalizedString(@"Rotate %d%@", @"Rotate %d%@"), degrees, [NSString degreeString]]];
}

- (void)changed
{
	[self changedInRect:NSMakeRect(0,0,[self size].width,[self size].height)];
}

- (void)changedInRect:(NSRect)rect
{
	if(NSEqualSizes([self size], NSZeroSize) || NSEqualRects(rect, NSZeroRect)) { return; }
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSValue valueWithRect:rect],
		PXChangedRectKey, 
		activeLayer, PXActiveLayerKey, 
		nil];
	
	[nc postNotificationName:PXCanvasChangedNotificationName
					  object:self
					userInfo:dict];
}

- (BOOL)canDrawAtPoint:(NSPoint)point
{
	if([self hasSelection])
	{
		if (![self pointIsSelected:point]) 
		{
			return NO; 
		}
	}
	return YES;
}

- (void)flipHorizontally
{
	[self beginUndoGrouping]; {
		NSEnumerator *enumerator = [layers objectEnumerator];
		PXLayer *current;
		while (current = [enumerator nextObject])
		{
			[self flipLayerHorizontally:current];
		}
	} [self endUndoGrouping:NSLocalizedString(@"Flip Canvas Horizontally", @"Flip Canvas Horizontally")];
}

- (void)flipVertically
{
	[self beginUndoGrouping]; {
		NSEnumerator *enumerator = [layers objectEnumerator];
		PXLayer *current;
		while (current = [enumerator nextObject])
		{
			[self flipLayerVertically:current];
		}
	} [self endUndoGrouping:NSLocalizedString(@"Flip Canvas Vertically", @"Flip Canvas Vertically")];
}

- (void)reduceColorsTo:(int)colors withTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor
{
	[PXCanvas reduceColorsInCanvases:[NSArray arrayWithObject:self] 
						toColorCount:colors
					withTransparency:transparency 
						  matteColor:matteColor];
}

+(void)reduceColorsInCanvases:(NSArray*)canvases 
				 toColorCount:(int)colors
			 withTransparency:(BOOL)transparency 
				   matteColor:(NSColor *)matteColor;
{
	PXCanvas *first = [canvases objectAtIndex:0];
	unsigned char *red = calloc([first size].width * [first size].height * [canvases count], sizeof(unsigned char));
	unsigned char *green = calloc([first size].width * [first size].height * [canvases count], sizeof(unsigned char));
	unsigned char *blue = calloc([first size].width * [first size].height * [canvases count], sizeof(unsigned char));
	PXPalette *palette = [first palette];
	int i;
	int quantizedPixels = 0;
	
	id enumerator = [canvases objectEnumerator], current;
	while (current = [enumerator nextObject])
	{
		if(!NSEqualSizes([first size], [current size]))
		{
			[NSException raise:@"Reduction Exception" format:@"Canvas sizes not equal!"];
		}
		if(palette != [current palette])
		{
			[NSException raise:@"Reduction Exception" format:@"Canvas palettes not identical!"];
		}
		NSImage *image = [[[current displayImage] copy] autorelease];
		id bitmapRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
		unsigned char *bitmapData = [bitmapRep bitmapData];
		
		if ([bitmapRep samplesPerPixel] == 3)
		{
			for (i = 0; i < [image size].width * [image size].height; i++)
			{
				int base = (i * 3);
				red[quantizedPixels + i] = bitmapData[base + 0];
				green[quantizedPixels + i] = bitmapData[base + 1];
				blue[quantizedPixels + i] = bitmapData[base + 2];
			}
			quantizedPixels += [image size].width * [image size].height;
		}
		else
		{
			for (i = 0; i < [image size].width * [image size].height; i++)
			{
				int base = (i * 4);
				if (bitmapData[base + 3] == 0 && transparency) { continue; }
				if (bitmapData[base + 3] < 255 && matteColor)
				{
					NSColor *sourceColor = [NSColor colorWithCalibratedRed:bitmapData[base + 0] / 255.0f green:bitmapData[base + 1] / 255.0f blue:bitmapData[base + 2] / 255.0f alpha:1];
					NSColor *resultColor = [matteColor blendedColorWithFraction:(bitmapData[base + 3] / 255.0f) ofColor:sourceColor];
					red[quantizedPixels] = [resultColor redComponent] * 255;
					green[quantizedPixels] = [resultColor greenComponent] * 255;
					blue[quantizedPixels] = [resultColor blueComponent] * 255;
				}
				else
				{
					red[quantizedPixels] = bitmapData[base + 0];
					green[quantizedPixels] = bitmapData[base + 1];
					blue[quantizedPixels] = bitmapData[base + 2];
				}
				quantizedPixels++;
			}
		}
	}
	
	GifColorType *map = malloc(sizeof(GifColorType) * 256);
	int size = colors - (transparency ? 1 : 0);
	unsigned char *output = malloc(sizeof(unsigned char*) * [first size].width * [first size].height * [canvases count]);
	if (quantizedPixels)
		QuantizeBuffer(quantizedPixels, &size, red, green, blue, output, map);
	//NSLog(@"Quantized to %d colors", size);
	PXPalette_postponeNotifications(palette, YES);
	[palette->undoManager beginUndoGrouping]; {
		if (colors < PXPalette_colorCount(palette))
		{
			while(palette->colorCount > 0)
			{
				PXPalette_removeColorAtIndex(palette, palette->colorCount - 1);
			}
			for (i = 0; i < size; i++)
			{
				PXPalette_addColor(palette, [NSColor colorWithCalibratedRed:map[i].Red / 255.0f green:map[i].Green / 255.0f blue:map[i].Blue / 255.0f alpha:1]);
			}
		}
		if (transparency)
			PXPalette_addColorWithoutDuplicating(palette, [NSColor clearColor]);
		
		enumerator = [canvases objectEnumerator];
		while (current = [enumerator nextObject])
		{
			id layerEnumerator = [[current layers] objectEnumerator], currentLayer;
			while(currentLayer = [layerEnumerator nextObject])
			{
				[currentLayer adaptToPaletteWithTransparency:transparency matteColor:matteColor];
			}
		}
	} [palette->undoManager endUndoGrouping];
	PXPalette_postponeNotifications(palette, NO);	
	free(red); free(green); free(blue); free(output); free(map);		
}
@end
