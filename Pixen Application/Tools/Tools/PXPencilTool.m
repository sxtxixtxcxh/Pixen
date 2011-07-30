//  PXPencilTool.m
//  Pixen

// Copyright (c) 2003,2004,2005 Pixen

// Permission is hereby granted, free of charge, to any person obtaining a copy

// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation 
// the rights  to use,copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom
//  the Software is  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

//  Created by Joe Osborn on Tue Sep 30 2003.
//

#import "PXPencilTool.h"
#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Drawing.h"
#import "PXCanvasController.h"
#import "PXPencilToolPropertiesController.h"
#import "InterpolatePoint.h"

@implementation PXPencilTool

#define PENCIL_PC ((PXPencilToolPropertiesController *) self.propertiesController)

- (NSString *)name
{
	return NSLocalizedString(@"PENCIL_NAME", @"Pencil Tool");
}

- (BOOL)shiftKeyDown
{
	if (isDragging) { return NO; }
	shiftDown = YES;
	return YES;
}

- (BOOL)shiftKeyUp
{
	shiftDown = NO;
	return YES;
}

-(id)  init
{
	if (! ( self = [super init] ) ) 
		return nil;
	
	shiftDown = NO;
	changedRect = NSZeroRect;
	return self;
}

- (PXToolPropertiesController *)createPropertiesController
{
	PXPencilToolPropertiesController *controller = [[PXPencilToolPropertiesController new] autorelease];
	[controller setToolName:[self name]];
	
	return controller;
}

-(NSString *)  actionName
{
	return NSLocalizedString(@"PENCIL_ACTION", @"Drawing");
}

- (void)drawWithOldColor:(NSColor *)oldColor 
				newColor:(NSColor *)newColor
				 atPoint:(NSPoint)aPoint
				 inLayer:(PXLayer *)aLayer 
				ofCanvas:(PXCanvas *) aCanvas
{
	if(![aCanvas canDrawAtPoint:aPoint]) 
    {
		return; 
    }
	if ([self shouldUseBezierDrawing])
	{
		[self.path appendBezierPathWithRect:NSMakeRect(aPoint.x, aPoint.y, 1, 1)];
		if ([aCanvas wraps]) {
			NSSize canvasSize = [aCanvas size];
			while (aPoint.x >= canvasSize.width) {
				aPoint.x -= canvasSize.width;
			}
			while (aPoint.y >= canvasSize.height) {
				aPoint.y -= canvasSize.height;
			}
			while (aPoint.x < 0) {
				aPoint.x += canvasSize.width;
			}
			while (aPoint.y < 0) {
				aPoint.y += canvasSize.height;
			}
			[self.wrappedPath appendBezierPathWithRect:NSMakeRect(aPoint.x, aPoint.y, 1, 1)];
		}
	}
	else// if (![oldColor isEqualTo:newColor])
	{
		[aCanvas bufferUndoAtPoint:aPoint fromColor:oldColor toColor:newColor];
		[aCanvas setColor:newColor atPoint:aPoint onLayer:aLayer];

		if (!NSEqualRects(changedRect, NSZeroRect)) {
			changedRect = NSUnionRect(changedRect, NSMakeRect(aPoint.x, aPoint.y, 1, 1));
		} else {
			changedRect = NSMakeRect(aPoint.x, aPoint.y, 1, 1);
		}
	}
}

- (void)drawPixelAtPoint:(NSPoint)aPoint inCanvas:(PXCanvas *)aCanvas
{
	if (![self.propertiesController respondsToSelector:@selector(lineThickness)]) {
		[self drawWithOldColor:[aCanvas colorAtPoint:aPoint] 
					  newColor:[self colorForCanvas:aCanvas] 
					   atPoint:aPoint 
					   inLayer:[aCanvas activeLayer] 
					  ofCanvas:aCanvas];
		return;
	}
	
	if ([PENCIL_PC drawingPoints] != nil) {
		NSArray *points = [PENCIL_PC drawingPoints];
		
		for (NSString *string in points)
		{
			NSPoint point = NSPointFromString(string);
			point.x += ceilf(aPoint.x - ([PENCIL_PC patternSize].width / 2));
			point.y += ceilf(aPoint.y - ([PENCIL_PC patternSize].height / 2));
			
			[self drawWithOldColor:[aCanvas colorAtPoint:point] 
						  newColor:[self colorForCanvas:aCanvas] 
						   atPoint:point 
						   inLayer:[aCanvas activeLayer]
						  ofCanvas:aCanvas];
		}
		
		return;
	}
	
	int diameter = [PENCIL_PC lineThickness];
	int radius = diameter/2;
	NSRect rect = NSMakeRect(aPoint.x-radius, aPoint.y-radius, diameter, diameter);
	int x,y;
	
	for (x=NSMinX(rect); x<NSMaxX(rect); x++) {
		for (y=NSMinY(rect); y<NSMaxY(rect); y++) {
			NSPoint loc = NSMakePoint(x,y);
			[self drawWithOldColor:[aCanvas colorAtPoint:loc] 
						  newColor:[self colorForCanvas:aCanvas] 
						   atPoint:loc 
						   inLayer:[aCanvas activeLayer] 
						  ofCanvas:aCanvas];
		}
	}
}

- (void)drawLineFrom:(NSPoint)initialPoint 
				  to:(NSPoint)finalPoint 
			inCanvas:(PXCanvas *) canvas
{
	NSPoint differencePoint = NSMakePoint(finalPoint.x - initialPoint.x, finalPoint.y - initialPoint.y);
    NSPoint currentPoint = initialPoint;    
    while(!NSEqualPoints(finalPoint, currentPoint))
    {
		currentPoint = InterpolatePointFromPointByPoint(currentPoint, initialPoint, differencePoint);
		if([canvas canDrawAtPoint:currentPoint])
		{
			[self drawPixelAtPoint:currentPoint inCanvas:canvas]; 
		}
    }
}

- (BOOL)shouldUseBezierDrawing
{
	return shouldUseBezierDrawing;
}

- (BOOL)drawsInitialPixel
{
	return YES;
}

- (void)mouseDownAt:(NSPoint)aPoint
fromCanvasController:(PXCanvasController*) controller
{
	[super mouseDownAt:aPoint fromCanvasController:controller];
	shouldUseBezierDrawing = NO;
	[[[controller canvas] undoManager] setActionName:[self actionName]];
	isDragging = YES;
	[[controller canvas] clearUndoBuffers];
	if (![self drawsInitialPixel]) { return; }
	if (!shiftDown || [controller lastDrawnPoint].x == -1) {
		[self drawPixelAtPoint:aPoint inCanvas:[controller canvas]];
		[[controller canvas] changedInRect:NSMakeRect(aPoint.x, aPoint.y, 1, 1)];
	} else {
		[self drawLineFrom:[controller lastDrawnPoint] to:aPoint inCanvas:[controller canvas]];
	}
	[controller setLastDrawnPoint:aPoint];
}

- (void)mouseMovedTo:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *)controller
{
	if([controller canvas] == nil) { return; }
	shouldUseBezierDrawing = YES;
	if ([self shouldUseBezierDrawing] && !NSEqualPoints(movingOrigin, aPoint))
	{	
		self.path = [NSBezierPath bezierPath];
		self.wrappedPath = [NSBezierPath bezierPath];
		
		movingOrigin = aPoint;
		[self drawPixelAtPoint:aPoint inCanvas:[controller canvas]];
		[[controller canvas] changedInRect:lastBezierBounds];
		if (![self.path isEmpty]) {
			NSRect bezierBounds = [self.path bounds];
			[[controller canvas] changedInRect:bezierBounds];
			lastBezierBounds = bezierBounds;
		}
	}
	if (self.isClicking) {
		shouldUseBezierDrawing = NO;
	}
}

- (void)clearBezier
{
	lastBezierBounds = NSZeroRect;
	movingOrigin = NSMakePoint(-1,-1);
	[self.path removeAllPoints];
}

- (NSRect)crosshairRectCenteredAtPoint:(NSPoint)aPoint
{
	if (self.path == nil || [self.path isEmpty] || ![[NSUserDefaults standardUserDefaults] boolForKey:PXToolPreviewEnabledKey]) {
		return [super crosshairRectCenteredAtPoint:aPoint];
	}
	return [self.path bounds];
}


- (void)mouseDraggedFrom:(NSPoint)initialPoint 
					  to:(NSPoint)finalPoint
    fromCanvasController:(PXCanvasController *)controller
{
	if (!shiftDown) {
		[controller setLastDrawnPoint:finalPoint];
		[self drawLineFrom:initialPoint to:finalPoint inCanvas:[controller canvas]];
		[self mouseMovedTo:finalPoint fromCanvasController:controller];
	}
	if (!NSEqualRects(changedRect, NSZeroRect))
	{
		[[controller canvas] changedInRect:changedRect];
		changedRect = NSZeroRect;
	}
}

- (void)mouseUpAt:(NSPoint)aPoint 
fromCanvasController:(PXCanvasController *) controller
{
	[[controller canvas] registerForUndo];
	[super mouseUpAt:aPoint fromCanvasController:controller];
	isDragging = NO;
	shouldUseBezierDrawing = NO;
	if (!NSEqualRects(changedRect, NSZeroRect))
	{
		[[controller canvas] changedInRect:changedRect];
		changedRect = NSZeroRect;
	}
}

- (BOOL)supportsPatterns
{
	return YES;
}

- (void)setPattern:(PXPattern *)pattern
{
	if (![self supportsPatterns]) { return; }
	[PENCIL_PC setPattern:pattern];
}

@end
