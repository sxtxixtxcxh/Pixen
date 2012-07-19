//
//  PXLayerRowView.m
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "PXLayerRowView.h"

@implementation PXLayerRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect
{
	if (self.selected)
	{
		NSColor *start = [NSColor colorWithCalibratedRed:138/255.0f green:165/255.0f blue:195/255.0f alpha:1.0f];
		NSColor *end = [NSColor colorWithCalibratedRed:94/255.0f green:118/255.0f blue:165/255.0f alpha:1.0f];
		
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:start endingColor:end];
		[gradient drawInRect:[self bounds] angle:90.0f];
	}
}

@end
