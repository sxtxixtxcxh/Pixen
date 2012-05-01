//
//  PXLinearTool.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXLinearTool.h"
#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvasController.h"
#import "PXCanvasDocument.h"

@implementation PXLinearTool

@synthesize origin = _origin;

-(id) init
{
	if (! ( self = [super init] ) )
        return nil;

    locked = NO;
	centeredOnOrigin = NO;
	return self;
}

- (NSPoint)transformOrigin:(NSPoint)origin withDrawingPoint:(NSPoint)aPoint
{
	if (centeredOnOrigin) {
		//  .      *      .
		//  3      10     17
		return NSMakePoint(2*origin.x - aPoint.x, 2*origin.y - aPoint.y);
	}
	return _origin;
}

- (void)fakeMouseDraggedIfNecessary;
{
	// kind of a HACK
	if (self.isClicking)
	{
//FIXME: coupled
		[self mouseDraggedFrom:_origin to:_lastPoint fromCanvasController:[[[NSDocumentController sharedDocumentController] currentDocument] canvasController]];
	}
}

- (BOOL)shiftKeyDown
{
    locked = YES;
	[self fakeMouseDraggedIfNecessary];
    return YES;
}

- (BOOL)shiftKeyUp
{
	locked = NO;
	[self fakeMouseDraggedIfNecessary];
	return YES;
}

- (BOOL)optionKeyDown
{
	centeredOnOrigin = YES;
	[self fakeMouseDraggedIfNecessary];
	return YES;
}

- (BOOL)optionKeyUp
{
	centeredOnOrigin = NO;
	[self fakeMouseDraggedIfNecessary];
	return YES;
}

- (BOOL)drawsInitialPixel
{
	return NO;
}

- (void)mouseDownAt:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *)controller
{
	[super mouseDownAt:aPoint fromCanvasController:controller];
	self.path = [NSBezierPath bezierPath];
	self.wrappedPath = [NSBezierPath bezierPath];
	_origin = aPoint;
}

- (void)finalDrawFromPoint:(NSPoint)origin
				   toPoint:(NSPoint)finalPoint
				  inCanvas:(PXCanvas *) canvas
{
    // General class, no implementation.
}

- (void)drawFromPoint:(NSPoint)origin 
			  toPoint:(NSPoint)finalPoint
			 inCanvas:(PXCanvas *)canvas
{
    // General class, no implementation. Besides this.
}

- (BOOL)supportsAdditionalLocking
{
    return NO;
}

- (NSPoint)lockedPointFromUnlockedPoint:(NSPoint)unlockedPoint 
							 withOrigin:(NSPoint)origin
{
	NSPoint modifiedFinal = unlockedPoint;
	if (locked) {
		float slope = (unlockedPoint.y - origin.y) / (unlockedPoint.x - origin.x);
		if ([self supportsAdditionalLocking]) {
			if (fabs(slope) < .25) {
				//y constant
				modifiedFinal.y = origin.y;
				return modifiedFinal;
			} else if (fabs(slope) < .75) {
				//x=2y ((but why do we need the +1??))
				modifiedFinal.x = origin.x + (slope > 0 ? 1 : -1) * 2 * (modifiedFinal.y-origin.y) + (unlockedPoint.x > origin.x ? 1 : -1);
				return modifiedFinal;
			} else if (fabs(slope) < 1.5) {
				//x=y
				modifiedFinal.x = origin.x + (slope > 0 ? 1 : -1) * (modifiedFinal.y - origin.y);
				return modifiedFinal;
			} else if (fabs(slope) < 3) {
				//y=2x ((but why do we need the +1??))
				modifiedFinal.y = origin.y + (slope > 0 ? 1 : -1) * 2 * (unlockedPoint.x-origin.x) + (unlockedPoint.x > origin.x ? 1 : -1);
				return modifiedFinal;
			} else {
				//x constant
				modifiedFinal.x = origin.x;
				return modifiedFinal;
			}
		}
		if (slope < 0) { // different diagonal
			modifiedFinal.x = origin.x - (unlockedPoint.y - origin.y);
		} else {
			modifiedFinal.x = origin.x + (unlockedPoint.y - origin.y);
		}
	}
	return modifiedFinal;
}

- (BOOL)drawsInitialPoint
{
	return FALSE;
}

- (void)mouseUpAt:(NSPoint)aPoint 
fromCanvasController:(PXCanvasController *)controller
{
	self.isClicking = NO;
	self.path = nil;
	self.wrappedPath = nil;
	
	NSPoint origin = [self transformOrigin:_origin withDrawingPoint:[self lockedPointFromUnlockedPoint:aPoint withOrigin:_origin]];
	
	[self finalDrawFromPoint:origin
					 toPoint:[self lockedPointFromUnlockedPoint:aPoint withOrigin:origin] 
					inCanvas:[controller canvas]];
	
	[super mouseUpAt:aPoint fromCanvasController:controller];
}

- (BOOL)shouldUseBezierDrawing
{
	return self.isClicking;
}

- (void)mouseDraggedFrom:(NSPoint)initialPoint 
					  to:(NSPoint)finalPoint 
    fromCanvasController:(PXCanvasController *)controller
{
	_lastPoint = finalPoint;
	NSPoint origin = [self transformOrigin:_origin withDrawingPoint:[self lockedPointFromUnlockedPoint:finalPoint withOrigin:_origin]];
	if (!NSEqualPoints(initialPoint, finalPoint)) 
    {
		[self.path removeAllPoints];
		[self.wrappedPath removeAllPoints];
		[self drawFromPoint:origin 
					toPoint:[self lockedPointFromUnlockedPoint:finalPoint withOrigin:origin]
				   inCanvas:[controller canvas]];
	}
	NSRect updateRect = lastBounds;
	if (self.path != nil && ![self.path isEmpty]) {
		updateRect = NSUnionRect(updateRect, [self.path bounds]);
		lastBounds = [self.path bounds];
	} else {
		lastBounds = NSZeroRect;
	}
	if (!NSEqualRects(updateRect, NSZeroRect)) {
		[[controller canvas] changedInRect:updateRect];
	}
}
@end
