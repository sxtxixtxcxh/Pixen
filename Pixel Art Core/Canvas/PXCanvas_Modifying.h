//
//  PXCanvas_Modifying.h
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvas.h"

@interface PXCanvas(Modifying)
- (BOOL)canDrawAtPoint:(NSPoint) aPoint;
- (NSColor*) colorAtPoint:(NSPoint) aPoint;
- (unsigned int)colorIndexAtPoint:(NSPoint)aPoint;
- (void)setColor:(NSColor *)aColor atPoint:(NSPoint)aPoint;
- (void)setColor:(NSColor *)aColor atPoints:(NSArray *)points;
- (void)setColorIndex:(unsigned int)index atPoint:(NSPoint)aPoint;
- (void)setColorIndex:(unsigned int)index atIndex:(unsigned int)loc;
- (void)setColorIndex:(unsigned int)index atIndices:(NSArray *)indices updateIn:(NSRect)bounds simpleUndo:(BOOL)assumeIndicesAreTheSameColor;
- (void)setColorIndex:(unsigned int)index atIndices:(NSArray *)indices updateIn:(NSRect)bounds onLayer:(PXLayer *)layer simpleUndo:(BOOL)assumeIndicesAreTheSameColor;
- (void)reduceColorsTo:(int)colors withTransparency:(BOOL)transparency matteColor:(NSColor *)matteColor;
+ (void)reduceColorsInCanvases:(NSArray*)canvases 
				  toColorCount:(int)colors
			  withTransparency:(BOOL)transparency 
					matteColor:(NSColor *)matteColor;

- (NSPoint)correct:(NSPoint)aPoint;
- (BOOL)containsPoint:(NSPoint)aPoint;
- (void)rotateByDegrees:(int)degrees;

- (void)beginOptimizedSetting;
- (void)endOptimizedSetting;

- (BOOL)wraps;
- (void)setWraps:(BOOL)newWraps;
- (void)setWraps:(BOOL)newWraps suppressRedraw:(BOOL)suppress;
- (void)changedInRect:(NSRect)rect;
- (void)changed;

- (void)flipHorizontally;
- (void)flipVertically;
@end
