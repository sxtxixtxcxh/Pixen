//
//  PXCanvas_Layers.h
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvas.h"

@interface PXCanvas(Layers)

- (PXLayer *) activeLayer;
- (void)activateLayer:(PXLayer *) aLayer;
- (NSArray *) layers;
- (NSUInteger)indexOfLayer:(PXLayer *) aLayer;
- (PXLayer *)layerNamed:(NSString *)name;

- (void)setLayers:(NSArray *) newLayers;
- (void)setLayers:(NSArray*)layers fromLayers:(NSArray *)oldLayers;
- (void)setLayers:(NSArray *) newLayers fromLayers:(NSArray *)oldLayers withDescription:(NSString *)desc;
- (void)setLayersNoResize:(NSArray *) newLayers fromLayers:(NSArray *)oldLayers;

- (void)addLayer:(PXLayer *)aLayer;
- (void)insertLayer:(PXLayer *) aLayer atIndex:(NSUInteger)index;
- (void)removeLayer: (PXLayer*) aLayer;
- (void)removeLayerAtIndex:(NSUInteger)index;

- (void)addTempLayer:(PXLayer *)layer;
- (void)insertTempLayer:(PXLayer *)layer atIndex:(NSUInteger)index;
- (void)removeTempLayer:(PXLayer *)layer;

- (void)moveLayerAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)targetIndex;
- (void)layersChanged;

- (void)rotateLayer:(PXLayer *)layer byDegrees:(int)degrees;

- (void)duplicateLayerAtIndex:(NSUInteger)index;
- (void)flipLayerHorizontally:aLayer;
- (void)flipLayerVertically:aLayer;

- (void)mergeDownLayer:aLayer;

- (void)moveLayer:(PXLayer *)layer byOffset:(NSPoint)offset;

@end
