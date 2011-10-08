//
//  PXLayerDetailsView.m
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
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
	if (self.selected) {
		[[NSColor alternateSelectedControlColor] set];
		NSRectFill(rect);
	}
}

@end
