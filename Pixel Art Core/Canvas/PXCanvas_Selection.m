//
//  PXCanvas_Selection.m
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXCanvas_Selection.h"

#import "NSImage+Reps.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_CopyPaste.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXLayer.h"

@implementation PXCanvas(Selection)

- (NSArray *)boundedRectsFromRect:(NSRect)rect
{
	return [NSArray arrayWithObject:NSStringFromRect(NSIntersectionRect(rect, NSMakeRect(0, 0, [self size].width, [self size].height)))];
}

- (void)promoteSelection
{
	[self beginUndoGrouping]; {
		PXLayer *newLayer = [[[PXLayer alloc] initWithName:NSLocalizedString(@"Promoted Selection", @"Promoted Selection")
													  size:[self size]
											 fillWithColor:PXGetClearColor()] autorelease];
		
		int i, j;
		NSPoint point;
		[newLayer setCanvas:self];
		
		NSUndoManager *um = [self undoManager];
		
		[self beginColorUpdates];
		
		for (i = 0; i < [self size].width; i++)
		{
			for (j = 0; j < [self size].height; j++)
			{
				if ([self pointIsSelected:NSMakePoint(i, j)])
				{
					point = NSMakePoint(i, j);
					[self setColor:[self colorAtPoint:point] atPoint:point onLayer:newLayer];
					[[um prepareWithInvocationTarget:self] setColor:[self colorAtPoint:point] atPoint:point];
					[self setColor:[self eraseColor] atPoint:point];
				}
			}
		}
		
		[self endColorUpdates];
		
		[self addLayer:newLayer];
		[self layersChanged];
		[self deselect];
	} [self endUndoGrouping:NSLocalizedString(@"Promote Selection to Layer", @"Promote Selection to Layer")];
}

- (void)setHasSelection:(BOOL)newSelection
{
	if (hasSelection != newSelection) {
		if (!hasSelection) {
			selectedRect = NSZeroRect;
		}
		hasSelection = newSelection;
		[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasSelectionStatusChangedNotificationName
															object:self];
	}
}

- (BOOL)hasSelection
{
	return hasSelection;
}

- (long)selectionMaskSize
{
	return sizeof(BOOL) * [self size].width * [self size].height;	
}

- (void)setMask:(PXSelectionMask)newMask withOldMask:(PXSelectionMask)oldMask
{
	[self setMaskData:[NSData dataWithBytesNoCopy:newMask length:[self selectionMaskSize]] 
	  withOldMaskData:[NSData dataWithBytesNoCopy:oldMask length:[self selectionMaskSize]]];
}

- (void)setMask:(PXSelectionMask)newMask
{
	PXSelectionMask currentMask = (PXSelectionMask)malloc([self selectionMaskSize]);
	memcpy(currentMask, [self selectionMask], [self selectionMaskSize]);
	[self setMask:newMask withOldMask:currentMask];
}

- (void)deselect
{
	if(![self hasSelection]) { return; }	
	[self beginUndoGrouping]; {
		PXSelectionMask newMask = malloc([self selectionMaskSize]);
		memset(newMask, NO, [self selectionMaskSize]);
		[self setMask:newMask];
		[[NSNotificationCenter defaultCenter] postNotificationName:PXSelectionMaskChangedNotificationName object:self];
		[self setHasSelection:NO];
//FIXME: redraw more intelligently
		[self changed];
	} [self endUndoGrouping:NSLocalizedString(@"Select None", @"Select None")];
}

- (void)deselectPixelAtPoint:(NSPoint)point
{
	[self setSelectionMaskBit:NO inRect:NSMakeRect(point.x, point.y, 1, 1)];
}

- (void)setSelectionMaskBit:(BOOL)bit atIndices:(NSArray *)indices
{
	[self beginUndoGrouping]; {
		NSMutableArray *changedIndices = [NSMutableArray arrayWithCapacity:[indices count]];
		unsigned currentValue;
		for (id current in indices)
		{
			currentValue = [current unsignedIntValue];
			if(selectionMask[currentValue] != bit)
			{
				[changedIndices addObject:current];
				selectionMask[currentValue] = bit;
			}
		}
		if(bit && [indices count])
		{
			[self setHasSelection:YES];
		}
		else
		{
			[self updateSelectionSwitch];
		}
//FIXME: find a way not to redraw the whole canvas
		[self changed];
		[[[self undoManager] prepareWithInvocationTarget:self] setSelectionMaskBit:!bit atIndices:changedIndices];
		selectedRect = NSZeroRect;
	} [self endUndoGrouping:NSLocalizedString(@"Selection", @"Selection")];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXSelectionMaskChangedNotificationName object:self];
}

- (void)selectPixelAtPoint:(NSPoint)point
{
	[self setSelectionMaskBit:YES inRect:NSMakeRect(point.x, point.y, 1, 1)];
}

- (void)setSelectionMaskBit:(BOOL)maskValue inRect:(NSRect)rect
{
	[self beginUndoGrouping]; {
//FIXME: NSIndexSet a better choice?  maybe use bitfields?
		NSMutableArray *changedIndices = [NSMutableArray arrayWithCapacity:1024];
		int i, j;
		int width = [self size].width;
		int height = [self size].height;
		for (j = NSMinY(rect); j < NSMaxY(rect); j++)
		{
			for (i = NSMinX(rect); i < NSMaxX(rect); i++)
			{
				NSPoint loc = NSMakePoint(i, j);
				unsigned index = (int)(loc.x) + (int)(height - loc.y - 1) * width;
				if(selectionMask[index] != maskValue)
				{
					[changedIndices addObject:[NSNumber numberWithUnsignedInt:index]];
					selectionMask[index] = maskValue;					
				}
			}
		}
		if (maskValue) {
			[self setHasSelection:YES];
			//can't just union them because we might be selecting across canvas tile boundaries in tile view
			selectedRect = NSZeroRect;
		} else {
			[self updateSelectionSwitch];
			selectedRect = NSZeroRect;
		}
		[[[self undoManager] prepareWithInvocationTarget:self] setSelectionMaskBit:!maskValue atIndices:changedIndices];
	} [self endUndoGrouping:NSLocalizedString(@"Selection", @"Selection")];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXSelectionMaskChangedNotificationName object:self];
	[self changedInRect:NSInsetRect([self selectedRect], -1, -1)];
}

- (void)selectPixelsInRect:(NSRect)rect
{
	[self setSelectionMaskBit:YES inRect:rect];
}

- (void)deselectPixelsInRect:(NSRect)rect
{
	[self setSelectionMaskBit:NO inRect:rect];
}

- (BOOL)indexIsSelected:(unsigned int)index
{
	if (![self hasSelection]) { return NO; }
	return selectionMask[index];
}

- (BOOL)pointIsSelected:(NSPoint)point
{
	if(![self hasSelection] || point.x < 0 || point.y < 0 || point.x >= [self size].width || point.y >= [self size].height)
		return NO; 
	
	if (!NSPointInRect(point, canvasRect)) { return NO; }
	
	return selectionMask[(int)(point.x + ([self size].height - point.y - 1) * [self size].width)];
}

- (NSData *)selectionData
{
	NSRect selectionRect = [self selectedRect];
	int i, j;
	PXLayer *tempLayer = [[[PXLayer alloc] initWithName:NSLocalizedString(@"Pasted Layer", @"Pasted Layer") size:[self size]] autorelease];
	[tempLayer setCanvas:self];
	
	[self beginColorUpdates];
	
	for (i = NSMinX(selectionRect); i < NSMaxX(selectionRect); i++)
	{
		for (j = NSMinY(selectionRect); j < NSMaxY(selectionRect); j++)
		{
			NSPoint point = NSMakePoint(i, j);
			if (![self pointIsSelected:point]) { continue; }
			[self setColor:[[self activeLayer] colorAtPoint:point]
						atPoint:point
             onLayer:tempLayer];
		}
	}
	
	[self endColorUpdates];
	
	return [NSKeyedArchiver archivedDataWithRootObject:tempLayer];
}

- (void)selectAll
{
	[self beginUndoGrouping]; {
		PXSelectionMask newMask = malloc([self selectionMaskSize]);
		memset(newMask, YES, [self selectionMaskSize]);
//FIXME: slow in large images, can it be avoided?
		[self setMask:newMask];
	} [self endUndoGrouping:NSLocalizedString(@"Select All", @"Select All")];
}

- (void)invertSelection
{
	[self beginUndoGrouping]; {
		PXSelectionMask newMask = malloc([self selectionMaskSize]);
		memcpy(newMask, selectionMask, [self selectionMaskSize]);
		int i;
		for (i = 0; i < [self selectionMaskSize]; i++)
		{
			newMask[i] = !(newMask[i]);
		}
		[self setMask:newMask];
	} [self endUndoGrouping:NSLocalizedString(@"Invert Selection", @"Invert Selection")];
}

- (void)updateSelectionSwitch
{
	int i, j;
	int width = [self size].width, height = [self size].height;
	for (i = 0; i < width; i++)
	{
		for (j = 0; j < height; j++)
		{
			if (selectionMask[i + (j * width)] == YES)
			{
				[self setHasSelection:YES];
				return;
			}
		}
	}
	
	[self setHasSelection:NO];
}

- (NSRect)selectedRect
{
	if (![self hasSelection]) {
		return NSZeroRect;
	}
	int width = [self size].width;
	int height = [self size].height;
	if (NSEqualRects(selectedRect, NSZeroRect))
	{
		int i, j;
		for (i = 0; i < width; i++)
		{
			for (j = 0; j < height; j++)
			{
				if(selectionMask[i + (height - j - 1) * width])
				{
					NSRect currentRect = NSMakeRect(i, j, 1, 1);
					if (NSEqualRects(selectedRect, NSZeroRect))
						selectedRect = currentRect;
					else
						selectedRect = NSUnionRect(selectedRect, currentRect);
				}
			}
		}
	}
	return selectedRect;
}

- (NSPoint)selectionOrigin
{
	return selectionOrigin;
}	

- (void)finalizeSelectionMotion
{
	int xOffset = selectionOrigin.x;
	int yOffset = selectionOrigin.y;
	NSSize size = [self size];
	int x, y, startX=0, startY=0, endX=size.width-1, endY=size.height-1, deltaX=1, deltaY=1;
	yOffset *= -1;
	if (yOffset > 0) {
		startY = endY;
		endY = 0;
		deltaY *= -1;
	}
	if (xOffset > 0) {
		startX = endX;
		endX = 0;
		deltaX *= -1;
	}
	[self beginUndoGrouping]; {
		NSData *oldMask = [NSData dataWithBytes:selectionMask length:[self selectionMaskSize]];
		PXSelectionMask sourceMask = selectionMask;
		for (y = startY; y*deltaY <= endY*deltaY; y+=deltaY)
		{
			for (x = startX; x*deltaX <= endX*deltaX; x+=deltaX)
			{
				NSPoint loc = NSMakePoint(x, y);
				NSPoint offLoc = NSMakePoint(x-xOffset, y-yOffset);
				unsigned initialIndex = (int)((int)(loc.x) + ((int)(loc.y) * size.width));
				unsigned finalIndex = (int)((int)(offLoc.x) + ((int)(offLoc.y) * size.width));
				if ((offLoc.x < 0 || offLoc.y < 0 || offLoc.x >= size.width || offLoc.y >= size.height)) 
				{
					selectionMask[initialIndex] = 0;
				} 
				else 
				{
					selectionMask[initialIndex] = sourceMask[finalIndex];
				}
			}
		}
//FIXME: slow in large images, can it be avoided?
		[self setMaskData:[NSData dataWithBytes:selectionMask length:[self selectionMaskSize]] withOldMaskData:oldMask];
	} [self endUndoGrouping:NSLocalizedString(@"Move Selection", @"Move Selection")];
	selectionOrigin = NSZeroPoint;
//FIXME: redraw more intelligently, change the selected rect appropriately rather than force its recaching
//	selectedRect.origin.x += xOffset;
//	selectedRect.origin.y -= yOffset;
//	if([self wraps])
//	{
		selectedRect = NSZeroRect;
//	}
//	else
//	{
//		selectedRect = NSIntersectionRect(selectedRect, NSMakeRect(0,0,[self size].width,[self size].height));
//	}
	[self updateSelectionSwitch];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXSelectionMaskChangedNotificationName object:self];
	[self changed];
}

- (void)translateSelectionMaskByX:(int)xOffset y:(int)yOffset
{
	selectionOrigin = NSMakePoint(selectionOrigin.x + xOffset, selectionOrigin.y + yOffset);
}

- (void)setSelectionOrigin:(NSPoint)orig
{
	selectionOrigin = orig;
}

- selectionDataWithType:(NSBitmapImageFileType)storageType
			 properties:(NSDictionary *)properties
{
	if (![self hasSelection])
		return [self imageDataWithType:storageType properties:properties];
	
	NSRect selectionRect = [self selectedRect];
	
	BOOL mergeLayers = [[properties objectForKey:PXMergeLayersKey] boolValue];
	NSBitmapImageRep *sourceImageRep = mergeLayers ? [self imageRep] : [activeLayer imageRep];
	
	NSBitmapImageRep *tempImageRep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																			  pixelsWide:selectionRect.size.width
																			  pixelsHigh:selectionRect.size.height
																		   bitsPerSample:8
																		 samplesPerPixel:4
																				hasAlpha:YES
																				isPlanar:NO
																		  colorSpaceName:NSCalibratedRGBColorSpace
																			 bytesPerRow:selectionRect.size.width * 4
																			bitsPerPixel:32] autorelease];
	
	for (int i = NSMinX(selectionRect); i < NSMaxX(selectionRect); i++)
	{
		for (int j = NSMinY(selectionRect); j < NSMaxY(selectionRect); j++)
		{
			if ([self pointIsSelected:NSMakePoint(i,j)])
			{
				NSUInteger m[4];
				[sourceImageRep getPixel:m atX:i y:[self size].height - j - 1];
				
				[tempImageRep setPixel:m atX:i - NSMinX(selectionRect) y:NSHeight(selectionRect) - 1 - (j - NSMinY(selectionRect))];
			}
		}
	}
	
	return [tempImageRep representationUsingType:storageType properties:properties];
}

- (PXSelectionMask)selectionMask
{
	return selectionMask;
}

- (void)setMaskData:(NSData *)mask withOldMaskData:(NSData *)prevMask
{
	NSRect prevSelectedRect = [self selectedRect];
	selectedRect = NSZeroRect;
	[self beginUndoGrouping]; {
		[[[self undoManager] prepareWithInvocationTarget:self] setMaskData:prevMask withOldMaskData:mask];
	} [self endUndoGrouping:NSLocalizedString(@"Selection", @"Selection")];
	if([prevMask length] != [mask length])
	{
		free(selectionMask);
		//is this okay?  MAXing here?  I really want to overhaul selection
		selectionMask = malloc(MAX([prevMask length], [mask length]));
		memset(selectionMask, 0, [mask length]);
	}
	//is this okay?  MINing here?  I really want to overhaul selection.
	memcpy(selectionMask, [mask bytes], MIN([mask length], [self selectionMaskSize]));
	// O(N)
	[self updateSelectionSwitch];
	[self changedInRect:NSInsetRect(NSUnionRect(prevSelectedRect,[self selectedRect]), -2, -2)];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXSelectionMaskChangedNotificationName object:self];
}

- (void)deleteSelection
{
	if (![self hasSelection])
		return;
	
	[self beginUndoGrouping]; {
		PXColor color = [self eraseColor];
		int i, j;
		
		[self clearUndoBuffers];
		[self beginColorUpdates];
		
		for (i = 0; i < [self size].width; i++)
		{
			for (j = 0; j < [self size].height; j++)
			{
				NSPoint point = NSMakePoint(i, j);
				
				if ([self pointIsSelected:point]) {
					PXColor oldColor = [activeLayer colorAtPoint:point];
					
					[self bufferUndoAtPoint:point fromColor:oldColor toColor:color];
					[self setColor:color atPoint:point onLayer:activeLayer];
				}
			}
		}
		
		[self registerForUndo];
		[self deselect];
		[self changed];
		[self endColorUpdates];
	} [self endUndoGrouping:NSLocalizedString(@"Delete Selection", @"Delete Selection")];
}

- (void)cropToSelection
{
	if (![self hasSelection])
		return;
	
	[self beginUndoGrouping]; {
		[self setSize:selectedRect.size
		   withOrigin:NSMakePoint(NSMinX(selectedRect) * -1, NSMinY(selectedRect) * -1)
	  backgroundColor:PXGetClearColor()];
		
		[self deselect];
	} [self endUndoGrouping:NSLocalizedString(@"Crop", @"Crop")];
}

@end
