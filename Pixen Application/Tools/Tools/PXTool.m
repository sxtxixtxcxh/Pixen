//
//  PXTool.m
//  Pixen
//
//  Copyright 2003-2012 Pixen Project. All rights reserved.
//

#import "PXTool.h"

#import "PXPalette.h"
#import "PXCanvas.h"
#import "PXCanvasController.h"
#import "PXToolPropertiesController.h"
#import "PXToolSwitcher.h"

@implementation PXTool

@synthesize isClicking, path, wrappedPath, switcher, color, propertiesController;

- (NSString *)name
{
	return @"";
}

- (id)init
{
	self = [super init];
	if (self) {
		path = [NSBezierPath bezierPath];
		wrappedPath = [NSBezierPath bezierPath];
		color = PXGetBlackColor();
		initialLoad = YES;
	}
	return self;
}

- (PXToolPropertiesController *)propertiesController
{
	if (initialLoad) {
		propertiesController = [self createPropertiesController];
		initialLoad = NO;
	}
	
	return propertiesController;
}

- (PXToolPropertiesController *)createPropertiesController
{
	return nil;
}

- (void)keyDown:(NSEvent *)event fromCanvasController:(PXCanvasController *)cc
{
	//no-op
}

- (void)mouseDownAt:(NSPoint)aPoint 
fromCanvasController:(PXCanvasController*)controller
{
//FIXME: move undo
	[[controller canvas] beginUndoGrouping];
	isClicking = YES;
}

- (BOOL)shouldUseBezierDrawing
{
	return NO;
}

- (NSCursor *)cursor
{
	return nil;
}

- (NSRect)crosshairRectCenteredAtPoint:(NSPoint)aPoint
{
	return NSMakeRect(aPoint.x, aPoint.y, 1, 1);
}

- (PXColor)colorForCanvas:(PXCanvas *)canvas
{
	return color;
}

- (void)recacheColorIfNecessaryFromController:(PXCanvasController*)controller
{
}

- (void)mouseDraggedFrom:(NSPoint)origin 
					  to:(NSPoint)destination 
    fromCanvasController:(PXCanvasController*) controller 
{
}

- (void)mouseMovedTo:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *)controller
{
	
}

- actionName
{
	return NSLocalizedString(@"Drawing", @"Drawing");
}

- (void)mouseUpAt:(NSPoint)point 
fromCanvasController:(PXCanvasController *)controller
{
	isClicking = NO;
//FIXME: move undo
	if ([[[controller canvas] undoManager] groupingLevel] > 0) {
		[[controller canvas] endUndoGrouping:[self actionName]];
	}
}

- (BOOL)shiftKeyDown 
{ 
	return NO; 
}

- (BOOL)shiftKeyUp 
{ 
	return NO;
}

- (BOOL)optionKeyDown 
{
	return NO; 
}

- (BOOL)optionKeyUp 
{ 
	return NO; 
}

- (BOOL)commandKeyDown 
{
	return NO; 
}

- (BOOL)commandKeyUp 
{ 
	return NO; 
}

- (BOOL)supportsPatterns
{
	return NO;
}

- (void)clearBezier { }

- (void)setPattern:(PXPattern *)pat
{
	
}

@end
