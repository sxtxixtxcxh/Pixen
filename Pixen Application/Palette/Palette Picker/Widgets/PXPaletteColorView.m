//
//  PXPaletteColorView.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXPaletteColorView.h"

#import "NSBezierPath+PXRoundedRectangleAdditions.h"

@implementation PXPaletteColorView

@synthesize color = _color, index = _index, controlSize = _controlSize, highlighted = _highlighted;

- (void)dealloc
{
	[_color release];
	[super dealloc];
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)drawColorSwatchWithFrame:(NSRect)rect
{
	// Draw that black/white alpha helper and use non-blind compositing. But only if we have to.
	if ([self.color alphaComponent] != 1)
	{
		NSPoint points[3];
		NSBezierPath *path = [NSBezierPath bezierPath];
		
		// First draw the black triangle, which covers the upper-left portion of the rect.
		points[0] = NSMakePoint(NSMinX(rect), NSMinY(rect));
		points[1] = NSMakePoint(NSMaxX(rect), NSMinY(rect));
		points[2] = NSMakePoint(NSMinX(rect), NSMaxX(rect));
		
		[path appendBezierPathWithPoints:points count:3];
		
		[[NSColor blackColor] set];
		[path fill];
		
		// Now for the white triangle.
		points[0] = NSMakePoint(NSMaxX(rect), NSMinY(rect));
		points[1] = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
		points[2] = NSMakePoint(NSMinX(rect), NSMaxY(rect));
		
		[path removeAllPoints];
		[path appendBezierPathWithPoints:points count:3];
		
		[[NSColor whiteColor] set];
		[path fill];
		
		// Now composite over the actual color.
		[self.color set];
		NSRectFillUsingOperation(rect, NSCompositeSourceOver);
	}
	else
	{
		// Nothing fancy's required; just paint the color.
		[self.color set];
		NSRectFill(rect);
	}
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect frame = [self bounds];
	[self.color set];
	
	[self drawColorSwatchWithFrame:frame];
	
	int fontSize = [NSFont systemFontSizeForControlSize:NSMiniControlSize];
	
	if (self.index > 9999)
		fontSize = floorf(fontSize * .85);
	
	NSAttributedString *badgeString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", self.index]
																	   attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:fontSize], NSFontAttributeName, nil]] autorelease];
	
	NSSize badgeSize = [badgeString size];
	badgeSize.width += 6.5f;
	badgeSize.height += 0;
	
	NSRect badgeRect = NSMakeRect(NSMaxX(frame) - badgeSize.width - 1.5f, NSMaxY(frame) - badgeSize.height - 2, badgeSize.width, badgeSize.height);
	
	if (!self.highlighted) {
		[[[NSColor grayColor] colorWithAlphaComponent:0.5f] set];
		NSFrameRectWithWidthUsingOperation(frame, 2.0f, NSCompositeSourceOver);
	}
	
	// Exceuse me for my mdrfkr hardcoded numbers and ternary operators.
	int verticalTextOffset = (self.index > 9999) ? 1 : 2;
	
	NSBezierPath *indexBadge = [NSBezierPath bezierPathWithRoundedRect:badgeRect
														  cornerRadius:5
															 inCorners:OSBottomLeftCorner];
	
	if ([self controlSize] != NSRegularControlSize) {
		return;
	}
	
	[[[NSColor grayColor] colorWithAlphaComponent:0.5f] set];
	[indexBadge fill];
	
	[badgeString drawAtPoint:NSMakePoint(NSMaxX(frame) - badgeSize.width + 3, NSMaxY(frame) - badgeSize.height - verticalTextOffset)];
	
	if (self.highlighted) {
		[[NSGraphicsContext currentContext] saveGraphicsState];
		NSSetFocusRingStyle(NSFocusRingOnly);
		[[NSBezierPath bezierPathWithRect:frame] fill];
		[[NSGraphicsContext currentContext] restoreGraphicsState];
	}
}

- (void)setControlSize:(NSControlSize)controlSize
{
	if (_controlSize != controlSize) {
		_controlSize = controlSize;
		[self setNeedsDisplay:YES];
	}
}

- (void)setIndex:(NSUInteger)newIndex
{
	if (_index != newIndex) {
		_index = newIndex;
		[self setNeedsDisplay:YES];
	}
}

- (void)setColor:(NSColor *)newColor
{
	if (_color != newColor) {
		[_color release];
		_color = [newColor retain];
		
		[self setNeedsDisplay:YES];
	}
}

- (void)setHighlighted:(BOOL)state
{
	if (_highlighted != state) {
		_highlighted = state;
		[self setNeedsDisplay:YES];
	}
}

@end
