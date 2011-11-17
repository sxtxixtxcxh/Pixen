//
//  PXDefaultBackgroundTemplateView.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXDefaultBackgroundTemplateView.h"

#import "NSBezierPath+PXRoundedRectangleAdditions.h"
#import "PXBackgroundPreviewView.h"

@implementation PXDefaultBackgroundTemplateView

@synthesize backgroundTypeText = _backgroundTypeText, activeDragTarget = _activeDragTarget;

- (void)dealloc
{
	[_backgroundTypeText release];
	[super dealloc];
}

- (void)setBackgroundTypeText:(NSString *)typeText
{
	if (_backgroundTypeText != typeText) {
		[_backgroundTypeText release];
		_backgroundTypeText = [typeText retain];
		
		NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Default %@", @"Default %@"), typeText];
		
		[self.templateClassNameField setStringValue:text];
	}
}

- (void)setActiveDragTarget:(BOOL)value
{
	if (_activeDragTarget != value) {
		_activeDragTarget = value;
		[self setNeedsDisplay:YES];
	}
}

- (void)setBackground:(PXBackground *)background
{
	[super setBackground:background];
	
	if (background == nil)
	{
		[self.templateNameField setHidden:YES];
		[self.templateClassNameField setHidden:YES];
		[self.imageView setHidden:YES];
	}
	else
	{
		[self.templateNameField setHidden:NO];
		[self.templateClassNameField setHidden:NO];
		[self.imageView setHidden:NO];
	}
	
	if (_backgroundTypeText)
	{
		[self setBackgroundTypeText:_backgroundTypeText];
	}
	
	[self setNeedsDisplay:YES];
}

- (void)drawDottedOutline
{
	NSBezierPath *dottedPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds], 7.0f, 7.0f)
														  cornerRadius:10.0f];
	[dottedPath setLineWidth:2.0f];
	
	CGFloat pattern[2] = { 9.0f, 3.0f };
	[dottedPath setLineDash:pattern count:2 phase:0.0f];
	
	NSColor *color = [self isHighlighted] ? [NSColor whiteColor] : [NSColor lightGrayColor];
	[[color colorWithAlphaComponent:0.5f] set];
	
	[dottedPath stroke];
}

- (void)drawNoDefaultText
{
	NSSize stringSize = NSMakeSize(180.0f, 20.0f);
	
	NSRect drawFrame;
	drawFrame.origin = NSMakePoint(NSWidth([self bounds]) / 2 - stringSize.width / 2, NSHeight([self bounds]) / 2 - stringSize.height / 2);
	drawFrame.size = stringSize;
	
	NSTextFieldCell *textCell = [[NSTextFieldCell alloc] init];
	[textCell setAlignment:NSCenterTextAlignment];
	[textCell setTextColor:[self isHighlighted] ? [NSColor whiteColor] : [NSColor disabledControlTextColor]];
	[textCell setStringValue:NSLocalizedString(@"Default Alternate Background", @"ALTERNATE_BACKGROUND_INFO")];
	[textCell drawWithFrame:drawFrame inView:self];
	[textCell release];
}

- (void)drawRect:(NSRect)rect
{
	if (_activeDragTarget)
	{
		NSFrameRectWithWidth([self bounds], 3.0f);
	}
	
	if (self.background == nil)
	{
		[self drawDottedOutline];
		[self drawNoDefaultText];
	}
	else
	{
		[super drawRect:rect];
	}
}

@end
