//
//  PXFillTool.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

//  This code is based on some from Will Leshner. Thanks, man!

#import "PXFillTool.h"

#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Layers.h"
#import "PXCanvasController.h"
#import "PXLayer.h"
#import "PXFillToolPropertiesController.h"
#import "NSColor+PXPaletteAdditions.h"

int CombineAxis(int Xaxis, int Yaxis, int width, int height);

int CombineAxis(int Xaxis, int Yaxis, int width, int height)
{
	return ((height - Yaxis) * width) + Xaxis;
}

#define FILL_PC ((PXFillToolPropertiesController *) self.propertiesController)

@implementation PXFillTool

- (NSString *)name
{
	return NSLocalizedString(@"FILL_NAME", @"Fill Tool");
}

- (NSString *)actionName
{
	return NSLocalizedString(@"FILL_ACTION", @"Fill");
}

- (PXToolPropertiesController *)createPropertiesController
{
	return [[PXFillToolPropertiesController new] autorelease];
}

- (NSCursor *)cursor
{
	return [[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"paintbucket_bw.png"]
									hotSpot:NSMakePoint(11.0f, 15.0f)] autorelease];
}

- (BOOL)commandKeyDown 
{
	FILL_PC.contiguous = !FILL_PC.contiguous;
	
	return NO; 
}

- (BOOL)commandKeyUp
{
	FILL_PC.contiguous = !FILL_PC.contiguous;
	
	return NO; 
}

- (BOOL)shouldAbandonFillingAtPoint:(NSPoint)aPoint fromCanvasController:(PXCanvasController *)controller
{
	if (![[controller canvas] containsPoint:aPoint])
		return YES;
	
	if (PXColorEqualsColor([self colorForCanvas:[controller canvas]], [[controller canvas] colorAtPoint:aPoint]))
		return YES;
	
	return NO;
}

- (void)mouseDownAt:(NSPoint)aPoint fromCanvasController:(PXCanvasController*)controller
{
	[super mouseDownAt:aPoint fromCanvasController:controller];
	if([self shouldAbandonFillingAtPoint:aPoint fromCanvasController:controller] || ([self checkSelectionOnCanvas:[controller canvas]] == YES && [[controller canvas] pointIsSelected:aPoint] == NO))
		return;
	
	[self fillPointsFromPoint:aPoint forCanvasController:controller];
	
}

- (void)fillPointsFromPoint:(NSPoint)aPoint forCanvasController:(PXCanvasController *)controller
{
	PXCanvas *canvas = [controller canvas];
	
	if (![canvas containsPoint:aPoint])
		return;
	
	PXColor initialColor = [canvas colorAtPoint:aPoint];
	PXColor fillColor = [self colorForCanvas:[controller canvas]];
	int canvasWidth = [canvas size].width;
	int canvasHeight = [canvas size].height;
	int tolerance = [FILL_PC tolerance];
	BOOL * points = (BOOL *)malloc((canvasWidth + 1) * (canvasHeight + 1) * sizeof(BOOL));
	memset(points, NO, (canvasWidth + 1) * (canvasHeight + 1));
	NSMutableArray * consideredPoints = [[NSMutableArray alloc] initWithCapacity:(canvasWidth * canvasHeight)];
	NSMutableArray * pointsToFill = [[NSMutableArray alloc] initWithCapacity:(canvasWidth * canvasHeight)];
	int index = CombineAxis(aPoint.x, aPoint.y, canvasWidth, canvasHeight);
	points[index] = YES;
	BOOL hasSelection = NO;
	if([self checkSelectionOnCanvas:canvas] == YES)
	{
		hasSelection = YES;
		if([canvas pointIsSelected:aPoint] == NO)
		{
			return;
		}	
	}	
	[canvas clearUndoBuffers];
	[consideredPoints addObject:[NSNumber numberWithInt:CombineAxis(aPoint.x, aPoint.y, canvasWidth, canvasHeight)]];
	[pointsToFill addObject:[NSNumber numberWithInt:CombineAxis(aPoint.x, aPoint.y, canvasWidth, canvasHeight)]];
	int xPointAxis;
	int yPointAxis;
	int leftBound = aPoint.x;
	int rightBound = aPoint.x;
	int upperBound = aPoint.y;
	int lowerBound = aPoint.y;
	NSPoint checkingPoint;
	PXLayer * activeLayer = [canvas activeLayer];
	if ([FILL_PC contiguous])
	{
		while([consideredPoints count] != 0)
		{
			xPointAxis = [[consideredPoints lastObject] intValue] % canvasWidth;
			yPointAxis = ([[consideredPoints lastObject] intValue] - ([[consideredPoints lastObject] intValue] % canvasWidth)) / canvasWidth ;
			[consideredPoints removeLastObject];
			checkingPoint = NSMakePoint(xPointAxis + 1, canvasHeight - yPointAxis);
			if(points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)] == NO && (hasSelection == NO || [canvas pointIsSelected:checkingPoint] == YES))
			{
				if(PXColorDistanceToColor([activeLayer colorAtPoint:checkingPoint], initialColor) <= tolerance  && [canvas containsPoint:checkingPoint] == YES)
				{
					NSNumber * pointIndex = [NSNumber numberWithInt:CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)];		
					points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  = YES;
					[consideredPoints addObject:pointIndex];
					[pointsToFill addObject:pointIndex];
					if(checkingPoint.x > rightBound)
					{
						rightBound = checkingPoint.x;
					}
					if(checkingPoint.x < leftBound)
					{
						leftBound = checkingPoint.x;
					}
				}
			}
			checkingPoint = NSMakePoint(xPointAxis - 1, canvasHeight - yPointAxis);
			if(points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  == NO && (hasSelection == NO || [canvas pointIsSelected:checkingPoint] == YES))
			{
				if(PXColorDistanceToColor([activeLayer colorAtPoint:checkingPoint], initialColor) <= tolerance && [canvas containsPoint:checkingPoint] == YES)
				{
					NSNumber * pointIndex = [NSNumber numberWithInt:CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)];		
					points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  = YES;
					[consideredPoints addObject:pointIndex];
					[pointsToFill addObject:pointIndex];
					if(checkingPoint.x > rightBound)
					{
						rightBound = checkingPoint.x;
					}
					if(checkingPoint.x < leftBound)
					{
						leftBound = checkingPoint.x;
					}
				}
			}
			checkingPoint = NSMakePoint(xPointAxis, canvasHeight - (yPointAxis + 1));
			if(points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  == NO && (hasSelection == NO || [canvas pointIsSelected:checkingPoint] == YES))
			{
				if(PXColorDistanceToColor([activeLayer colorAtPoint:checkingPoint], initialColor) <= tolerance  && [canvas containsPoint:checkingPoint] == YES)
				{
					NSNumber * pointIndex = [NSNumber numberWithInt:CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)];
					points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  = YES;
					[consideredPoints addObject:pointIndex];
					[pointsToFill addObject:pointIndex];
					if(checkingPoint.y > upperBound)
					{
						upperBound = checkingPoint.y;
					}
					if(checkingPoint.y < lowerBound)
					{
						lowerBound = checkingPoint.y;
					}
				}
			}
			checkingPoint = NSMakePoint(xPointAxis, canvasHeight - (yPointAxis - 1));
			if(points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  == NO && (hasSelection == NO || [canvas pointIsSelected:checkingPoint] == YES))
			{
				if(PXColorDistanceToColor([activeLayer colorAtPoint:checkingPoint], initialColor) <= tolerance && [canvas containsPoint:checkingPoint] == YES)
				{
					NSNumber * pointIndex = [NSNumber numberWithInt:CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)];
					points[CombineAxis(checkingPoint.x, checkingPoint.y, canvasWidth, canvasHeight)]  = YES;
					[consideredPoints addObject:pointIndex];
					[pointsToFill addObject:pointIndex];
					if(checkingPoint.y > upperBound)
					{
						upperBound = checkingPoint.y;
					}
					if(checkingPoint.y < lowerBound)
					{
						lowerBound = checkingPoint.y;
					}
				}
			}
		}
	}
	else
	{
		[pointsToFill removeAllObjects];
		int i;
		leftBound = 0;
		lowerBound = 0;
		rightBound = canvasWidth - 1;
		upperBound = canvasHeight - 1;
		for (i = 0; i < canvasWidth * canvasHeight; i++)
		{
			if (PXColorDistanceToColor([activeLayer colorAtIndex:i], initialColor) <= tolerance && (hasSelection == NO || [canvas indexIsSelected:i] == YES))
			{
				[pointsToFill addObject:[NSNumber numberWithInt:i+canvasWidth]]; // not sure why this works...
			}
		}
	}
	NSRect bounds = NSMakeRect(leftBound, lowerBound, rightBound - leftBound + 1, upperBound - lowerBound + 1);
	[self fillPixelsInBOOLArray:pointsToFill withColor:fillColor withBoundsRect:bounds ofCanvas:canvas];
	[consideredPoints release];
	[pointsToFill release];
	free(points);
	[canvas registerForUndo];
}

- (void)fillPixelsInBOOLArray:(NSArray *)fillPoints withColor:(PXColor)newColor withBoundsRect:(NSRect)bounds ofCanvas:(PXCanvas *)canvas
{
	int canvasWidth = [canvas size].width;
	id indices = [NSMutableArray arrayWithCapacity:[fillPoints count]];
	for (id current in fillPoints)
	{
		int val = [current intValue];
		int xLoc = val % canvasWidth;
		int yLoc = (val - (val % canvasWidth))/canvasWidth - 1;
		[indices addObject:[NSNumber numberWithInt:xLoc + (yLoc * canvasWidth)]];
	}
	
	[canvas setColor:newColor atIndices:indices updateIn:bounds];
	[canvas changedInRect:bounds];
}

- (BOOL)checkSelectionOnCanvas:(PXCanvas *)canvas
{ 
	return [canvas hasSelection];
}

@end
