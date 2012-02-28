//
//  PXMagicWandTool.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXMagicWandTool.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvasController.h"
#import "PXTool.h"
#import "PXLayer.h"
#import "PXImage.h"
#import "PXToolSwitcher.h"
#import "PXNotifications.h"

@implementation PXMagicWandTool

- (NSString *)name
{
	return NSLocalizedString(@"MAGICWAND_NAME", @"Magic Wand Tool");
}

- (NSCursor *)cursor
{
	return [[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"magic_bw"]
									hotSpot:NSMakePoint(4.0f, 4.0f)] autorelease];
}

- (BOOL)shiftKeyDown
{
	isAdding = YES;
	[self.switcher setIcon:[NSImage imageNamed:@"magicadd"] forTool:self];
	return YES;
}

- (BOOL)shiftKeyUp
{
	isAdding = NO;
	[self.switcher setIcon:[NSImage imageNamed:@"magic"] forTool:self];
	return YES;
}

- (BOOL)optionKeyDown
{
	isSubtracting = YES;
	[self.switcher setIcon:[NSImage imageNamed:@"magicsubtract"] forTool:self];
	return YES;
}

- (BOOL)optionKeyUp
{
	isSubtracting = NO;
	[self.switcher setIcon:[NSImage imageNamed:@"magic"] forTool:self];
	return YES;
}

-(NSString *) actionName
{
	return NSLocalizedString(@"MAGICWAND_ACTION", @"Selection");
}

- (void)startMovingCanvas:(PXCanvas *) canvas
{
	selectedRect = [canvas selectedRect];
	lastSelectedRect = NSZeroRect;
	isMoving = YES;
}

- (void)stopMovingCanvas:(PXCanvas *) canvas
{
	isMoving = NO;
	selectedRect = lastSelectedRect; 
	[[canvas activeLayer] finalizeMotion];
}

- (BOOL)shouldAbandonFillingAtPoint:(NSPoint)aPoint 
			   fromCanvasController:(PXCanvasController *) controller
{
	return NO;
}

- (void)mouseDownAt:(NSPoint)aPoint 
fromCanvasController:(PXCanvasController *) controller
{
	[[controller canvas] beginUndoGrouping];
	origin = aPoint;
	if([[controller canvas] pointIsSelected:aPoint] && !isSubtracting && !isAdding)
    {
		lastSelectedRect = [[controller canvas] selectedRect];
		[self startMovingCanvas:[controller canvas]];
    }	
	else
    {
		if (!isAdding && !isSubtracting)
		{
			selectedRect = NSZeroRect;
			[[controller canvas] deselect];
		}
		[super mouseDownAt:aPoint fromCanvasController:controller];
    }
}

- (void)mouseDraggedFrom:(NSPoint)initialPoint 
					  to:(NSPoint)finalPoint 
    fromCanvasController:(PXCanvasController *) controller
{
	if(isMoving)
    {
		NSPoint differencePoint = NSMakePoint(finalPoint.x - initialPoint.x, finalPoint.y - initialPoint.y);
		[[controller canvas] translateSelectionMaskByX:differencePoint.x y:differencePoint.y];
		selectedRect.origin.x += differencePoint.x;
		selectedRect.origin.y += differencePoint.y;
		[[controller canvas] changedInRect:NSInsetRect(NSUnionRect(selectedRect, lastSelectedRect), -1, -1)];
		lastSelectedRect = selectedRect;
    }
}

- (void)mouseUpAt:(NSPoint)aPoint 
fromCanvasController:(PXCanvasController *)controller
{
	PXCanvas *canvas = [controller canvas];
	if(isMoving)
    {
		[self stopMovingCanvas:canvas];
		if (NSEqualPoints(origin, aPoint))
		{
			[canvas deselect];
		}
		else
		{	
			[canvas finalizeSelectionMotion];
		}
    }
	else
	{
		[super mouseUpAt:aPoint fromCanvasController:controller];
	}
	[[controller canvas] endUndoGrouping:[self actionName]];
}

- (BOOL)checkSelectionOnCanvas:(PXCanvas *)canvas
{
	return NO;
}	

- (void)fillPixelsInBOOLArray:(NSArray *)fillPoints withColor:(PXColor)newColor withBoundsRect:(NSRect)bounds ofCanvas:(PXCanvas *)canvas
{
	id indices = [NSMutableArray arrayWithCapacity:[fillPoints count]];
	for (id current in fillPoints)
	{
		[indices addObject:[NSNumber numberWithInt:[current intValue] - [canvas size].width]];
	}
	[canvas setSelectionMaskBit:!isSubtracting atIndices:indices];
	[canvas changedInRect:bounds]; 
}

@end
