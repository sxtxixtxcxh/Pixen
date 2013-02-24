//
//  PXClickableView.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXClickableView.h"

@implementation PXClickableView

@synthesize selected = _selected;

- (void)setSelected:(BOOL)selected
{
	if (_selected != selected) {
		_selected = selected;
		[self setNeedsDisplay:YES];
	}
}

- (void)drawRect:(NSRect)dirtyRect
{
	if (self.selected) {
		[[NSColor selectedControlColor] set];
		[[NSBezierPath bezierPathWithRoundedRect:[self bounds]
										 xRadius:4.0f
										 yRadius:4.0f] fill];
	}
}

@end
