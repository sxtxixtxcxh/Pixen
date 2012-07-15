//
//  PXNewCelButton.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXNewCelButton.h"

#import "NSBezierPath+PXRoundedRectangleAdditions.h"

@implementation PXNewCelButton

@synthesize delegate = _delegate;

const CGFloat PXPlusButtonSize = 12.0f;
const CGFloat PXPlusButtonPadding = 12.0f;

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		_buttonPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds], 4.0f, 4.0f) cornerRadius:10.0f];
		[_buttonPath setLineWidth:2.5f];
		
		CGFloat pattern[2] = { 9.0f, 3.0f };
		[_buttonPath setLineDash:pattern count:2 phase:0.0f];
		
		_plusPath = [NSBezierPath bezierPath];
		[_plusPath setLineWidth:2.0f];
		
		NSPoint tempPoint = NSMakePoint(NSMaxX([self bounds]) - PXPlusButtonSize / 2 - PXPlusButtonPadding,
										NSMaxY([self bounds]) - PXPlusButtonSize - PXPlusButtonPadding);
		[_plusPath moveToPoint:tempPoint];
		
		tempPoint.y += PXPlusButtonSize;
		[_plusPath lineToPoint:tempPoint];
		
		tempPoint.x -= PXPlusButtonSize / 2;
		tempPoint.y -= PXPlusButtonSize / 2;
		[_plusPath moveToPoint:tempPoint];
		
		tempPoint.x += PXPlusButtonSize;
		[_plusPath lineToPoint:tempPoint];
		
		[self setToolTip:NSLocalizedString(@"ADD_CEL", @"ADD_CEL")];
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	[ (_state == NSOnState) ? [NSColor whiteColor] : [NSColor lightGrayColor] set];
	
	[_buttonPath stroke];
	[_plusPath stroke];
}

- (void)mouseDown:(NSEvent *)event
{
	_state = NSOnState;
	
	[self setNeedsDisplay:YES];
}

- (BOOL)containsWindowPoint:(NSPoint)point
{
	return NSPointInRect([self convertPoint:point fromView:nil], [self bounds]);
}

- (void)mouseDragged:(NSEvent *)event
{
	if ([self containsWindowPoint:[event locationInWindow]])
	{
		if (_state == NSOnState)
			return;
		
		_state = NSOnState;
	}
	else
	{
		if (_state == NSOffState)
			return;
		
		_state = NSOffState;
	}
	
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event
{
	_state = NSOffState;
	
	[self setNeedsDisplay:YES];
	
	if ([self containsWindowPoint:[event locationInWindow]])
	{
		if ([self.delegate respondsToSelector:@selector(newCelButtonClicked:)])
		{
			[self.delegate newCelButtonClicked:self];
		}
	}
}

@end
