//
//  PXLayerTableView.m
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "PXLayerTableView.h"

@implementation PXLayerTableView

- (BOOL)acceptsFirstResponder
{
	return NO;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[super mouseDown:theEvent];
	
	if (theEvent.clickCount < 2)
		return;
	
	NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:nil];
	NSInteger row = [self rowAtPoint:point];
	
	if (row < 0)
		return;
	
	NSTableCellView *view = [self viewAtColumn:0 row:row makeIfNecessary:NO];
	
	point = [view convertPoint:point fromView:self];
	
	if (NSPointInRect(point, view.textField.frame)) {
		[view.textField mouseDown:theEvent];
	}
}

@end
