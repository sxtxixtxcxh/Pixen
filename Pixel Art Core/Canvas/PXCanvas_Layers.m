//
//  PXCanvas_Layers.m
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Selection.h"
#import "PXLayer.h"
#import "NSMutableArray+ReorderingAdditions.h"
#import "NSString_DegreeString.h"

@implementation PXCanvas(Layers)

- (void)setLayers:(NSArray *) newLayers fromLayers:(NSArray *)oldLayers
{
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] setLayers:oldLayers 
															  fromLayers:newLayers];
		NSSize oldSize = [self size];
		[self setLayers:newLayers];
		NSSize sz = [self size];
		if (!NSEqualSizes(oldSize, sz))
		{
			unsigned newMaskLength = sizeof(BOOL) * sz.width * sz.height;
			PXSelectionMask newMask = calloc(sz.width * sz.height, sizeof(BOOL));
			NSData *newData = [NSData dataWithBytes:newMask length:newMaskLength];
			NSData *oldData = [NSData dataWithBytes:selectionMask length:[self selectionMaskSize]];
			[self setMaskData:newData withOldMaskData:oldData];
			free(newMask);
			[[NSNotificationCenter defaultCenter] postNotificationName:PXSelectionMaskChangedNotificationName object:self];
			selectedRect = NSZeroRect;
			[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasSizeChangedNotificationName object:self];
		}
	} [self endUndoGrouping];
}

- (void)setLayersNoResize:(NSArray *) newLayers fromLayers:(NSArray *)oldLayers
{
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] setLayersNoResize:oldLayers 
																	  fromLayers:newLayers];
		NSSize oldSize = [self size];
		[self setLayers:newLayers];
		if (!NSEqualSizes(oldSize, [self size]))
		{
			[self updatePreviewSize];
			[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasSizeChangedNotificationName object:self];
		}
	} [self endUndoGrouping];
}

- (PXLayer *)activeLayer
{
	return activeLayer;
}

- (void)activateLayer:(PXLayer *)aLayer
{
	if (!aLayer)
		return;
	
	activeLayer = aLayer;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:PXCanvasLayerSelectionDidChangeNotificationName object:self];
}

- (void)layersChanged
{
	[self changed];
}

- (NSArray *) layers
{
	return layers;	
}

- (NSUInteger)indexOfLayer:(PXLayer *)aLayer
{
	return [layers indexOfObject:aLayer];
}

- (PXLayer *)layerNamed:(NSString *)name
{
	for (PXLayer *current in layers)
	{
		if ([current.name isEqualToString:name])
			return current;
	}
	
	return nil;
}

- (void)setLayers:(NSArray *) newLayers
{
	if (layers == newLayers)
		return;
	
	NSMutableArray *mutableNewLayers = [newLayers mutableCopy];
	NSUInteger oldActiveIndex = [layers indexOfObject:activeLayer];
	
	if ( [mutableNewLayers count] <= oldActiveIndex )
		oldActiveIndex = [mutableNewLayers count]-1;
	
	for (PXLayer *layer in mutableNewLayers)
	{
		[layer setCanvas:self];
	}
	
	layers = mutableNewLayers;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasSetLayersNotificationName object:self];
	
	[self activateLayer:[mutableNewLayers objectAtIndex:oldActiveIndex]];
	[self refreshWholePalette];
	[self layersChanged];
}

- (void)addLayer:(PXLayer *)aLayer
{
	[self beginUndoGrouping]; {
		[self insertLayer:aLayer atIndex:[layers count]];
	} [self endUndoGrouping];
}

- (void)insertLayer:(PXLayer *) aLayer atIndex:(NSUInteger)index
{
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] removeLayer:aLayer];
		[aLayer setCanvas:self];
		[layers insertObject:aLayer atIndex:index];
		
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
							  aLayer, PXLayerKey,
							  [NSNumber numberWithUnsignedInteger:index], PXLayerIndexKey, nil];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasAddedLayerNotificationName
															object:self
														  userInfo:info];
		
		[self activateLayer:aLayer];
		[self refreshWholePalette];
		[self changed];
	} [self endUndoGrouping];
}

- (void)removeLayer: (PXLayer*) aLayer
{
	[self removeLayerAtIndex:[layers indexOfObject:aLayer]];
}

- (void)removeLayerAtIndex:(NSUInteger)index
{
	BOOL wasActive = ([self indexOfLayer:activeLayer] == index);
	PXLayer *layer = [layers objectAtIndex:index];
	[self beginUndoGrouping]; {
		NSUInteger newIndex = [layers indexOfObject:layer];
		[[[self undoManager] prepareWithInvocationTarget:self] insertLayer:layer atIndex:index];
		[layers removeObject:layer];
		
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithUnsignedInteger:index-1], PXLayerIndexKey, nil];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasRemovedLayerNotificationName
															object:self
														  userInfo:info];
		
		if(newIndex >= [layers count])
		{
			newIndex = [layers count] - 1;
		}
		if(wasActive)
		{
			[self activateLayer:[layers objectAtIndex:newIndex]];
		}
		[self changed];
		[self refreshWholePalette];
	} [self endUndoGrouping];
}

- (void)addTempLayer:(PXLayer *)layer
{
	[self insertTempLayer:layer atIndex:[tempLayers count]];
}

- (void)insertTempLayer:(PXLayer *)layer atIndex:(NSUInteger)index
{
	if (!tempLayers)
		tempLayers = [[NSMutableArray alloc] init];
	
	[tempLayers insertObject:layer atIndex:index];
	
	[self changed];
}

- (void)removeTempLayer:(PXLayer *)layer
{
	[tempLayers removeObject:layer];
	
	[self changed];
}

- (void)moveLayerAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)targetIndex
{
	if (sourceIndex >= [layers count])
		sourceIndex = [layers count] - 1;
	
	if (targetIndex == NSNotFound || targetIndex >= [layers count])
		targetIndex = [layers count] - 1;
	
	if (sourceIndex == targetIndex)
		return;
	
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] moveLayerAtIndex:targetIndex toIndex:sourceIndex];
		
		[layers moveObjectAtIndex:sourceIndex toIndex:targetIndex];
		
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithUnsignedInteger:sourceIndex], PXSourceIndexKey,
							  [NSNumber numberWithUnsignedInteger:targetIndex], PXTargetIndexKey, nil];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasMovedLayerNotificationName
															object:self
														  userInfo:info];
		
		[self activateLayer:[layers objectAtIndex:targetIndex]];
		[self changed];
	} [self endUndoGrouping];
}

- (void)rotateLayer:(PXLayer *)layer byDegrees:(int)degrees
{
	if (![layers containsObject:layer])
		return;
	
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] rotateLayer:layer
																 byDegrees:360 - degrees];
		
		NSSize previousCanvasSize = [self size];
		
		[layer rotateByDegrees:degrees];
		
		if (!NSEqualSizes([self size], previousCanvasSize)) {
			[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasSizeChangedNotificationName
																object:self];
		}
		else {
			if (!NSEqualSizes([layer size], previousCanvasSize))
				[layer setSize:previousCanvasSize];
		}
		
		[self changed];
	} [self endUndoGrouping];
}

- (void)duplicateLayerAtIndex:(NSUInteger)index
{
	PXLayer *result = [[layers objectAtIndex:index] copy];
	
	[self beginUndoGrouping]; {
		result.name = [result.name stringByAppendingString:NSLocalizedString(@" Copy", @" Copy")];
		
		[self insertLayer:result atIndex:index+1];
	} [self endUndoGrouping];
}

- (void)flipLayerHorizontally:aLayer
{
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] flipLayerHorizontally:aLayer];
		[aLayer flipHorizontally];
	} [self endUndoGrouping];
	[self changed];
}

- (void)flipLayerVertically:aLayer
{
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] flipLayerVertically:aLayer];
		[aLayer flipVertically];
	} [self endUndoGrouping];
	[self changed];
}

- (void)mergeDownLayer:aLayer
{
	BOOL wasActive = aLayer == activeLayer;
	NSUInteger index = [layers indexOfObject:aLayer];
	[self beginUndoGrouping]; {
		[self setLayers:[layers deepMutableCopy] fromLayers:layers];
		[[layers objectAtIndex:index-1] compositeUnder:[layers objectAtIndex:index] flattenOpacity:YES];
		[self removeLayerAtIndex:index];
		if(wasActive)
		{
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0);
			dispatch_after(popTime, dispatch_get_main_queue(), ^{
				
				[self activateLayer:[layers objectAtIndex:index - 1]];
				
			});
		}
	} [self endUndoGrouping];
}

- (void)moveLayer:(PXLayer *)layer byOffset:(NSPoint)offset
{
	[self beginUndoGrouping]; {
		NSData *colorData = [layer colorData];
		[[[self undoManager] prepareWithInvocationTarget:self] restoreColorData:colorData onLayer:layer];
		
		[layer translateContentsByOffset:offset];
	} [self endUndoGrouping:NSLocalizedString(@"MOVE_ACTION", nil)];
	
	[self changed];
	[self refreshWholePalette];
}

@end
