//
//  PXLayerDetailsView.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXLayerDetailsView.h"

@implementation PXLayerDetailsView

@synthesize selected = _selected;

- (BOOL)acceptsFirstResponder
{
	return NO;
}

- (void)setSelected:(BOOL)state
{
	if (_selected != state) {
		_selected = state;
		[self setNeedsDisplay:YES];
	}
}

- (void)drawRect:(NSRect)rect
{
	if (self.selected)
	{
		NSColor *start = [NSColor colorWithCalibratedRed:138/255.0f green:165/255.0f blue:195/255.0f alpha:1.0f];
		NSColor *end = [NSColor colorWithCalibratedRed:94/255.0f green:118/255.0f blue:165/255.0f alpha:1.0f];
		
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:start endingColor:end];
		[gradient drawInRect:[self bounds] angle:270.0f];
	}
}

@end
