//
//  PXMoveTool.m
//  Pixen-XCode
//

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

//  Created by Andy Matuschak on Fri Feb 27 2004.
//  Copyright (c) 2004 Pixen. All rights reserved.
//

#import "PXMoveTool.h"
#import "PXCanvasController.h"
#import "PXCanvas.h"
#import "PXCanvasDocument.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"
#import "PXImage.h"

@implementation PXMoveTool

- (PXToolPropertiesController *)createPropertiesController
{
	return nil;
}

- (NSString *)name
{
	return NSLocalizedString(@"MOVE_NAME", @"Move Tool");
}

-(NSString *)actionName
{
	return NSLocalizedString(@"MOVE_ACTION", @"Moving");
}

- (NSCursor *)cursor
{
	return [NSCursor openHandCursor];
}

- (void)startMovingSelectionFromPoint:(NSPoint)aPoint fromCanvasController:(PXCanvasController *)controller
{
	PXCanvas *canvas = [controller canvas];
	
	lastSelectedRect = selectedRect = [canvas selectedRect]; // O(N)
	selectionOrigin = selectedRect.origin;
	
	moveLayer = [[PXLayer alloc] initWithName:NSLocalizedString(@"Temp Layer", @"Temp Layer")
										 size:selectedRect.size];
	[moveLayer setCanvas:canvas];
	[moveLayer setOpacity:[[canvas activeLayer] opacity]];
	
	// we clear the selected area in the active layer and copy the selected pixels
	// into a pximage of our own to be drawn each frame. whoo.
	// this is O(N), incidentally. but just over selected pixels, not the whole canvas.
	int i, j;
	NSColor *clear = [canvas eraseColor];
	for (i = NSMinX(selectedRect); i < NSMaxX(selectedRect); i++)
	{
		for (j = NSMinY(selectedRect); j < NSMaxY(selectedRect); j++)
		{
			NSPoint point = NSMakePoint(i, j);
			
			if (![canvas pointIsSelected:point])
				continue;
			
			[canvas setColor:[canvas colorAtPoint:point]
					 atPoint:NSMakePoint(i - selectedRect.origin.x, j - selectedRect.origin.y)
					 onLayer:moveLayer];
			
			[canvas setColor:clear atPoint:point];
		}
	}
	
	[moveLayer moveToPoint:selectedRect.origin]; // move to initial point
	[canvas addTempLayer:moveLayer];
}

- (void)mouseDownAt:(NSPoint)aPoint fromCanvasController:(PXCanvasController *)controller
{
	[super mouseDownAt:aPoint fromCanvasController:controller];
	
	if ([NSEvent modifierFlags] & NSAlternateKeyMask) {
		type = PXMoveTypeCopying;
	}
	else {
		type = PXMoveTypeMoving;
	}
	
	PXCanvas *canvas = [controller canvas];
	[canvas beginUndoGrouping];
	
	if ([canvas hasSelection])
	{
		entireImage = NO;
		[self startMovingSelectionFromPoint:aPoint fromCanvasController:controller];
	}
	else {
		entireImage = YES;
		moveLayer = [canvas activeLayer];
		selectionOrigin = NSZeroPoint;
	}
	
	if (type == PXMoveTypeCopying) {
		[self updateCopyLayerForCanvas:canvas];
	}
}

- (void)updateCopyLayerForCanvas:(PXCanvas *)canvas
{
	if (!entireImage) {
		if (type == PXMoveTypeCopying) {
			copyLayer = [moveLayer copy];
			[copyLayer moveToPoint:selectionOrigin];
			
			[canvas insertTempLayer:copyLayer atIndex:0];
		}
		else if (type == PXMoveTypeMoving) {
			[canvas removeTempLayer:copyLayer];
			[copyLayer release];
			copyLayer = nil;
		}
	}
	else {
		if (type == PXMoveTypeMoving) {
			NSPoint origin = [copyLayer origin];
			
			[canvas removeTempLayer:copyLayer];
			[copyLayer release];
			copyLayer = nil;
			
			[moveLayer moveToPoint:origin];
		}
		else if (type == PXMoveTypeCopying) {
			NSPoint origin = [moveLayer origin];
			[moveLayer moveToPoint:NSZeroPoint];
			
			copyLayer = [moveLayer copy];
			[copyLayer moveToPoint:origin];
			
			[canvas insertTempLayer:copyLayer atIndex:0];
		}
	}
}

- (void)drawFromPoint:(NSPoint)initialPoint
			  toPoint:(NSPoint)finalPoint
			 inCanvas:(PXCanvas *)canvas
{
	float dx = (finalPoint.x - initialPoint.x), dy = (finalPoint.y - initialPoint.y);
	
	if (!entireImage)
	{
		selectedRect.origin = NSMakePoint(selectionOrigin.x + dx, selectionOrigin.y + dy);
		[moveLayer moveToPoint:selectedRect.origin];
		
		[canvas setSelectionOrigin:NSMakePoint(dx, dy)];
		[canvas changedInRect:NSInsetRect(NSUnionRect(selectedRect, lastSelectedRect), -1, -1)];
		
		lastSelectedRect = selectedRect;
	}
	else
	{
		if (type == PXMoveTypeMoving) {
			[[canvas activeLayer] moveToPoint:NSMakePoint(dx, dy)];
		}
		else if (type == PXMoveTypeCopying) {
			[copyLayer moveToPoint:NSMakePoint(dx, dy)];
		}
		
		[canvas changedInRect:NSMakeRect(0.0f, 0.0f, [canvas size].width, [canvas size].height)];
	}
}

- (BOOL)supportsAdditionalLocking
{
	return YES;
}

- (void)finalDrawFromPoint:(NSPoint)initialPoint
				   toPoint:(NSPoint)finalPoint
				  inCanvas:(PXCanvas *)canvas
{
	if (!entireImage)
	{
		selectedRect = lastSelectedRect;
		
		if (type == PXMoveTypeCopying)
		{
			[copyLayer setSize:[canvas size]];
			[copyLayer finalizeMotion];
			
			[[canvas activeLayer] compositeUnder:copyLayer flattenOpacity:YES];
			
			[canvas removeTempLayer:copyLayer];
			[copyLayer release];
			copyLayer = nil;
		}
		
		[moveLayer setSize:[canvas size]];
		[moveLayer finalizeMotion];
		
		[[canvas activeLayer] compositeUnder:moveLayer flattenOpacity:YES];
		
		[canvas removeTempLayer:moveLayer];
		[moveLayer release];
		moveLayer = nil;
		
		[canvas finalizeSelectionMotion];
		[canvas changed];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:PXSelectionMaskChangedNotificationName
															object:canvas];
	}
	else
	{
		[canvas moveLayer:moveLayer byX:[moveLayer origin].x y:[moveLayer origin].y];
		[moveLayer moveToPoint:NSZeroPoint];
		
		if (type == PXMoveTypeCopying)
		{
			[copyLayer setSize:[canvas size]];
			[copyLayer finalizeMotion];
			
			[[canvas activeLayer] compositeUnder:copyLayer flattenOpacity:YES];
			
			[canvas removeTempLayer:copyLayer];
			[copyLayer release];
			copyLayer = nil;
		}
		
		entireImage = NO;
		moveLayer = nil;
	}
	
	type = PXMoveTypeNone;
	[canvas endUndoGrouping:[self actionName]];
}

- (void)keyDown:(NSEvent *)event fromCanvasController:(PXCanvasController *)cc
{
	NSPoint nudgeDest = NSZeroPoint;
	int nudgeAmount = 1;
	
	if (([event modifierFlags] & NSShiftKeyMask) == NSShiftKeyMask) {
		nudgeAmount = 10;
	}
	
	if ([[event characters] characterAtIndex:0] == NSUpArrowFunctionKey) {
		nudgeDest.y = nudgeAmount;
	}
	else if ([[event characters] characterAtIndex:0] == NSRightArrowFunctionKey) {
		nudgeDest.x = nudgeAmount;
	}
	else if ([[event characters] characterAtIndex:0] == NSDownArrowFunctionKey) {
		nudgeDest.y = -nudgeAmount;
	}
	else if ([[event characters] characterAtIndex:0] == NSLeftArrowFunctionKey) {
		nudgeDest.x = -nudgeAmount;
	}
	
	if (!NSEqualPoints(nudgeDest, NSZeroPoint)) {
		[self mouseDownAt:NSZeroPoint fromCanvasController:cc];
		[self mouseDraggedFrom:NSZeroPoint to:nudgeDest fromCanvasController:cc];
		[self mouseUpAt:nudgeDest fromCanvasController:cc];
	}
}

- (BOOL)optionKeyDown
{
	if (type == PXMoveTypeNone)
		return YES;
	
	type = PXMoveTypeCopying;
	
	PXCanvasDocument *doc = (PXCanvasDocument *) [[NSDocumentController sharedDocumentController] currentDocument];
	[self updateCopyLayerForCanvas:[[doc canvasController] canvas]];
	
	return YES;
}

- (BOOL)optionKeyUp
{
	if (type == PXMoveTypeNone)
		return YES;
	
	type = PXMoveTypeMoving;
	
	PXCanvasDocument *doc = (PXCanvasDocument *) [[NSDocumentController sharedDocumentController] currentDocument];
	[self updateCopyLayerForCanvas:[[doc canvasController] canvas]];
	
	return YES;
}

@end
