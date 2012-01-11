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
	[self setLayers:newLayers fromLayers:oldLayers withDescription:NSLocalizedString(@"Set Layers", @"Set Layers")];
}

- (void)setLayers:(NSArray *) newLayers fromLayers:(NSArray *)oldLayers withDescription:(NSString *)desc
{
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] setLayers:oldLayers 
															  fromLayers:newLayers
														 withDescription:desc];
		NSSize oldSize = [self size];
		[self setLayers:newLayers];
		NSSize sz = [self size];
		if (!NSEqualSizes(oldSize, sz))
		{
			unsigned newMaskLength = sizeof(BOOL) * sz.width * sz.height;
			PXSelectionMask newMask = calloc(sz.width * sz.height, sizeof(BOOL));
			id newData = [NSData dataWithBytes:newMask length:newMaskLength];
			id oldData = [NSData dataWithBytes:selectionMask length:[self selectionMaskSize]];
			[self setMaskData:newData withOldMaskData:oldData];
			free(newMask);
			[[NSNotificationCenter defaultCenter] postNotificationName:PXSelectionMaskChangedNotificationName object:self];
			selectedRect = NSZeroRect;
			[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasSizeChangedNotificationName object:self];
		}
	} [self endUndoGrouping:desc];
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
	} [self endUndoGrouping:NSLocalizedString(@"Set Layers", @"Set Layers")];
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
	
	[layers release];
	layers = mutableNewLayers;
	
	[self activateLayer:[mutableNewLayers objectAtIndex:oldActiveIndex]];
	[self refreshWholePalette];
	[self layersChanged];
}

- (void)addLayer:(PXLayer *)aLayer
{
	[self beginUndoGrouping]; {
		[self insertLayer:aLayer atIndex:[layers count]];
	} [self endUndoGrouping:NSLocalizedString(@"Add Layer", @"Add Layer")];
}

- (void)replaceLayer:(PXLayer *)old withLayer:(PXLayer *)new actionName:(NSString *)act
{
	NSInteger index = [layers indexOfObject:old];
	NSInteger activeIndex = [layers indexOfObject:activeLayer];
	if(index == NSNotFound) { return; }
	[self beginUndoGrouping]; {
		[[undoManager prepareWithInvocationTarget:self] replaceLayer:new withLayer:old actionName:act];
		[new setCanvas:self];
		[layers replaceObjectAtIndex:index withObject:new];
		if(activeIndex != NSNotFound)
		{
			[self activateLayer:[layers objectAtIndex:activeIndex]];
		}
		if(![layers containsObject:activeLayer])
		{
			[self activateLayer:new];
		}
		[self layersChanged];
		[self changed];
		[self refreshWholePalette];
	} [self endUndoGrouping:act];
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
	} [self endUndoGrouping:NSLocalizedString(@"Insert Layer", @"Insert Layer")];
}

- (void)removeLayer: (PXLayer*) aLayer
{
	[self removeLayerAtIndex:[layers indexOfObject:aLayer]];
}

- (void)removeLayerAtIndex:(NSUInteger)index
{
	BOOL wasActive = ([self indexOfLayer:activeLayer] == index);
	id layer = [layers objectAtIndex:index];
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
	} [self endUndoGrouping:NSLocalizedString(@"Remove Layer", @"Remove Layer")];	
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
	} [self endUndoGrouping:NSLocalizedString(@"Reorder Layer", @"Reorder Layer")];
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
	} [self endUndoGrouping:[NSString stringWithFormat:NSLocalizedString(@"Rotate Layer", @"Rotate Layer"), degrees, [NSString degreeString]]];
}

- (void)duplicateLayerAtIndex:(NSUInteger)index
{
	PXLayer *result = [[[layers objectAtIndex:index] copy] autorelease];
	result.name = [result.name stringByAppendingString:NSLocalizedString(@" Copy", @" Copy")];
	
	[self beginUndoGrouping]; {
		[self insertLayer:result atIndex:index+1];
	} [self endUndoGrouping:NSLocalizedString(@"Duplicate Layer", @"Duplicate Layer")];
}

- (void)flipLayerHorizontally:aLayer
{
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] flipLayerHorizontally:aLayer];
		[aLayer flipHorizontally];
	} [self endUndoGrouping:NSLocalizedString(@"Flip Layer Horizontally", @"Flip Layer Horizontally")];
	[self changed];
}

- (void)flipLayerVertically:aLayer
{
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] flipLayerVertically:aLayer];
		[aLayer flipVertically];
	} [self endUndoGrouping:NSLocalizedString(@"Flip Layer Vertically", @"Flip Layer Vertically")];
	[self changed];
}

- (void)mergeDownLayer:aLayer
{
	BOOL wasActive = aLayer == activeLayer;
	NSUInteger index = [layers indexOfObject:aLayer];
	[self beginUndoGrouping]; {
		[[layers objectAtIndex:index-1] compositeUnder:[layers objectAtIndex:index] flattenOpacity:YES];
		[self removeLayerAtIndex:index];
		if(wasActive)
		{
			[self activateLayer:[layers objectAtIndex:index - 1]];		
		}
	} [self endUndoGrouping:NSLocalizedString(@"Merge Down", @"Merge Down")];
}

- (void)moveLayer:(PXLayer *)layer byX:(int)x y:(int)y
{
	[layer setOrigin:NSMakePoint(x, y)];
	PXLayer *new = [layer layerAfterApplyingMove];
	[new setOrigin:NSZeroPoint];
	[self replaceLayer:layer withLayer:new actionName:NSLocalizedString(@"Move", @"Move")];
}

@end
