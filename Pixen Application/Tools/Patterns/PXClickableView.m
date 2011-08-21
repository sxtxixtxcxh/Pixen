//
//  PXClickableView.m
//  Pixen
//
//  Created by Matt Rajca on 8/20/11.
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import "PXClickableView.h"

@implementation PXClickableView

- (void)mouseDown:(NSEvent *)theEvent
{
	if ([theEvent clickCount] > 1) {
		if ([delegate respondsToSelector:@selector(viewDidReceiveDoubleClick:)])
			[delegate viewDidReceiveDoubleClick:self];
	}
	else {
		[super mouseDown:theEvent];
	}
}

- (void)setSelected:(BOOL)selected
{
	if (_selected != selected) {
		_selected = selected;
		[self setNeedsDisplay:YES];
	}
}

- (void)drawRect:(NSRect)dirtyRect
{
	if (_selected) {
		[[NSColor selectedControlColor] set];
		[[NSBezierPath bezierPathWithRoundedRect:[self bounds]
										 xRadius:4.0f
										 yRadius:4.0f] fill];
	}
}

@end
