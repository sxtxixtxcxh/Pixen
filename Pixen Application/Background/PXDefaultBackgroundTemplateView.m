//
//  PXDefaultBackgroundTemplateView.m
//  Pixen
//

#import "PXDefaultBackgroundTemplateView.h"
#import "NSBezierPath+PXRoundedRectangleAdditions.h"

@implementation PXDefaultBackgroundTemplateView

@synthesize backgroundTypeText;

- (void)dealloc
{
	[backgroundTypeText release];
	[super dealloc];
}

- (void)setBackgroundTypeText:(NSString *)typeText;
{
	[backgroundTypeText release];
	backgroundTypeText = [typeText retain];
	[self.templateClassNameField setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Default %@", @"Default %@"), backgroundTypeText]];
}

- (void)setActiveDragTarget:(BOOL)adt
{
	activeDragTarget = adt;
	[self setNeedsDisplay:YES];
}

- (void)setBackground:(PXBackground *)bg
{
	[super setBackground:bg];
	if (bg == nil)
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
	
	if (backgroundTypeText)
	{
		[self setBackgroundTypeText:backgroundTypeText];
	}
	[self setNeedsDisplay:YES];
}

- (void)drawDottedOutline
{
	NSBezierPath *dottedPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds], 7, 7)
														  cornerRadius:10];
	[dottedPath setLineWidth:2];
	CGFloat pattern[2] = { 9.0, 3.0 };
	[dottedPath setLineDash:pattern count:2 phase:0.0];
	[[(highlighted ? [NSColor whiteColor] : [NSColor lightGrayColor]) colorWithAlphaComponent:0.5] set];
	[dottedPath stroke];	
}

- (void)drawNoDefaultText
{
	NSSize stringSize = NSMakeSize(180, 20);
	NSRect drawFrame;
	drawFrame.origin = NSMakePoint(NSWidth([self bounds]) / 2 - stringSize.width / 2, NSHeight([self bounds]) / 2 - stringSize.height / 2);
	drawFrame.size = stringSize;
	
	NSTextFieldCell *textCell = [[NSTextFieldCell alloc] init];
	[textCell setAlignment:NSCenterTextAlignment];
	[textCell setTextColor:(highlighted) ? [NSColor whiteColor] : [NSColor disabledControlTextColor]];
	[textCell setStringValue:NSLocalizedString(@"Default Alternate Background", @"ALTERNATE_BACKGROUND_INFO")];
	[textCell drawWithFrame:drawFrame inView:self];
    [textCell release];
}

- (void)drawRect:(NSRect)rect
{
	if (activeDragTarget)
	{
		NSFrameRectWithWidth([self bounds], 3);
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

- (void)setHighlighted:(BOOL)h
{
	highlighted = h;
	[super setHighlighted:highlighted];
}

@end
