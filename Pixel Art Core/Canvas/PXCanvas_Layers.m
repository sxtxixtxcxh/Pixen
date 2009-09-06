//
//  PXCanvas_Layers.m
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"
#ifndef __COCOA__
#include <math.h>
#import "PXNotifications.h"
#import "PXDefaults.h"
#endif
#import "NSString_DegreeString.h"

@implementation PXCanvas(Layers)

- (void)setLayers:(NSArray *) newLayers fromLayers:(NSArray *)oldLayers
{
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] setLayers:oldLayers 
															  fromLayers:newLayers];
		NSSize oldSize = [self size];
		[self setLayers:newLayers];
		if (!NSEqualSizes(oldSize, [self size]))
		{
			[self setSize:[self size]];
			[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasSizeChangedNotificationName object:self];
		}
	} [self endUndoGrouping:NSLocalizedString(@"Set Layers", @"Set Layers")];
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
	if( (activeLayer == aLayer) || (aLayer == nil) ) return; 
	if([[self undoManager] groupingLevel] != 0) { [[[self undoManager] prepareWithInvocationTarget:self] activateLayer:activeLayer]; }
	activeLayer = aLayer;
}

- (void)layersChanged
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:PXCanvasLayersChangedNotificationName object:self];
	[self changed];
}

- (NSArray *) layers
{
	return layers;	
}

- (int)indexOfLayer:(PXLayer *)aLayer
{
	return [layers indexOfObject:aLayer];
}

- (void)setLayers:(NSArray *) newLayers
{
	if(layers == newLayers)
	{
		return;
	}
	[newLayers retain];
	int oldActiveIndex = [layers indexOfObject:activeLayer];
	int i;
	
	if ( [newLayers count] <= oldActiveIndex ) 
		oldActiveIndex = 0; 
	
	
	for (i=0; i<[newLayers count]; i++) 
	{
		[[newLayers objectAtIndex:i] setCanvas:self];
	}
	[self activateLayer:[newLayers objectAtIndex:oldActiveIndex]];
	[layers autorelease];
	
	layers = newLayers;
	
	[self layersChanged];
}

- (void)addLayer:(PXLayer *) aLayer suppressingNotification:(BOOL)suppress
{
	[self beginUndoGrouping]; {
		[self insertLayer:aLayer atIndex:[layers count] suppressingNotification:suppress];
		if(!suppress)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasLayersChangedNotificationName
																object:self
															  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																  aLayer, PXCanvasNewLayerKey,
																  [NSNumber numberWithInt:[layers count] - 1], PXCanvasOldLayersCountKey, nil]];
		}
	} [self endUndoGrouping:NSLocalizedString(@"Add Layer", @"Add Layer")];
}

- (void)addLayer:(PXLayer *)aLayer
{
	[self addLayer:aLayer suppressingNotification:NO];
}

- (void)replaceLayer:(PXLayer *)old withLayer:(PXLayer *)new actionName:(NSString *)act
{
	unsigned index = [layers indexOfObject:old];
	unsigned activeIndex = [layers indexOfObject:activeLayer];
	if(index == NSNotFound) { return; }
	[self beginUndoGrouping]; {
		[[undoManager prepareWithInvocationTarget:self] replaceLayer:new withLayer:old actionName:act];
		[new setCanvas:self];
		[[old retain] autorelease];
		[layers removeObjectAtIndex:index];
		[layers insertObject:new atIndex:index];
		if(activeIndex != NSNotFound)
		{
			[self activateLayer:[layers objectAtIndex:activeIndex]];
		}
		if(![layers containsObject:activeLayer])
		{
			[self activateLayer:new];
		}
		[new recache];
		[self layersChanged];
		[self changed];
	} [self endUndoGrouping:act];
}

- (void)insertLayer:(PXLayer *) aLayer atIndex:(int)index suppressingNotification:(BOOL)suppress
{
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] removeLayer:aLayer];
		[aLayer setCanvas:self];
		[layers insertObject:aLayer atIndex:index];
		[self activateLayer:aLayer];
		if(!suppress)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasLayersChangedNotificationName
																object:self
															  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																  [NSNumber numberWithInt:[layers count] - 1], PXCanvasOldLayersCountKey, nil]];
		}
		[self changed];
	} [self endUndoGrouping:NSLocalizedString(@"Insert Layer", @"Insert Layer")];
}

- (void)insertLayer:(PXLayer *) aLayer atIndex:(int)index
{
	[self insertLayer:aLayer atIndex:index suppressingNotification:NO];
}

- (void)removeLayer: (PXLayer*) aLayer
{
	[self removeLayerAtIndex:[layers indexOfObject:aLayer] suppressingNotification:NO];
}

- (void)removeLayer: (PXLayer*) aLayer suppressingNotification:(BOOL)suppress
{
	[self removeLayerAtIndex:[layers indexOfObject:aLayer] suppressingNotification:YES];
}

- (void)removeLayerAtIndex:(int)index suppressingNotification:(BOOL)suppress
{
	id layer = [layers objectAtIndex:index];
	[self beginUndoGrouping]; {
		int newIndex = [layers indexOfObject:layer];
		[[[self undoManager] prepareWithInvocationTarget:self] insertLayer:layer atIndex:index];
		[[layer retain] autorelease];
		[layers removeObject:layer];
		if(newIndex >= [layers count])
		{
			newIndex = [layers count] - 1;
		}
		if(!suppress)
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasLayersChangedNotificationName object:self];
		}
		if(activeLayer == layer)
		{
			[self activateLayer:[layers objectAtIndex:newIndex]];
		}
		[self changed];
	} [self endUndoGrouping:NSLocalizedString(@"Remove Layer", @"Remove Layer")];	
}

- (void)removeLayerAtIndex:(int)index
{
	[self removeLayerAtIndex:index suppressingNotification:NO];
}

- (void)moveLayer:(PXLayer*) aLayer toIndex:(int)targetIndex
{
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] moveLayer:aLayer toIndex:[layers indexOfObject:aLayer]];
		id newLayers = [layers mutableCopy];
		int sourceIndex = [layers indexOfObject:aLayer];
		if (targetIndex != -1)
		{
			id residentLayer = [layers objectAtIndex:targetIndex];
			[newLayers removeObjectAtIndex:sourceIndex];
			[newLayers insertObject:aLayer atIndex:[newLayers indexOfObject:residentLayer]+1];
		}
		else
		{
			[newLayers removeObjectAtIndex:sourceIndex];
			[newLayers insertObject:aLayer atIndex:0];
		}
		[layers release];
		layers = newLayers;		
	} [self endUndoGrouping:NSLocalizedString(@"Reorder Layer", @"Reorder Layer")];
	[self layersChanged];
}

- (void)rotateLayer:(PXLayer *)layer byDegrees:(int)degrees
{
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] rotateLayer:layer byDegrees:360 - degrees];
		NSSize oldSize = [self size];
		int index = [layers indexOfObject:layer];
		if(index == -1) { return; }
		[layer rotateByDegrees:degrees];
		if (!NSEqualSizes(oldSize, [self size]))
		{
			[self setSize:[self size]];
			[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasSizeChangedNotificationName object:self];
		}
		[self changed];
	} [self endUndoGrouping:[NSString stringWithFormat:NSLocalizedString(@"Rotate Layer", @"Rotate Layer"), degrees, [NSString degreeString]]];
}

- (void)duplicateLayerAtIndex:(unsigned)index
{
	[self beginUndoGrouping]; {
		[self insertLayer:[[[layers objectAtIndex:index] copy] autorelease] atIndex:index];
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
	int index = [layers indexOfObject:aLayer];
	[self beginUndoGrouping]; {
		[self setLayers:[layers deepMutableCopy] fromLayers:layers];
		[[layers objectAtIndex:index-1] compositeUnder:[layers objectAtIndex:index] flattenOpacity:YES];
		[self removeLayerAtIndex:index];
	} [self endUndoGrouping:NSLocalizedString(@"Merge Down", @"Merge Down")];
}

- (void)moveLayer:(PXLayer *)aLayer byX:(int)x y:(int)y
{
	PXLayer *new = [activeLayer layerAfterApplyingMove];
	[activeLayer setOrigin:NSZeroPoint];
	[self replaceLayer:activeLayer withLayer:new actionName:NSLocalizedString(@"Move", @"Move")];
}

- (void)removeColorIndicesAfter:(unsigned)maxIndex
{
#warning stupid undo
	[self setLayers:[[layers deepMutableCopy] autorelease] fromLayers:layers];
	id enumerator = [layers objectEnumerator], current;
	while(current = [enumerator nextObject])
	{
		[current removeColorIndicesAfter:maxIndex];
	}
}

@end
