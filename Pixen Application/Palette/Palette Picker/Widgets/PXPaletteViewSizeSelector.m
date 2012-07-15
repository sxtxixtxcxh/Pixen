//
//  PXPaletteViewSizeSelector.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXPaletteViewSizeSelector.h"

@implementation PXPaletteViewSizeSelector

@synthesize controlSize = _controlSize, delegate = _delegate;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		if ([NSColor currentControlTint] == NSGraphiteControlTint)
		{
			_smallImage = [NSImage imageNamed:@"palette_small_graphite"];
			_bigImage = [NSImage imageNamed:@"palette_big_graphite"];
		}
		else
		{
			_smallImage = [NSImage imageNamed:@"palette_small_aqua"];
			_bigImage = [NSImage imageNamed:@"palette_big_aqua"];
		}
		
		self.controlSize = NSRegularControlSize;
    }
    return self;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
	return YES;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (NSString *)toolTip
{
	return @"Switch to large swatch mode";
}

- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)userData
{
	if (point.y > ceilf(NSHeight([self bounds])/2))
		return NSLocalizedString(@"SHOW_LARGE_COLOR_SWATCHES", @"Show large color swatches");
	else
		return NSLocalizedString(@"SHOW_SMALL_COLOR_SWATCHES", @"Show small color swatches");
}

- (void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
	[self removeAllToolTips];
	
	NSRect upper, lower;
	NSDivideRect([self bounds], &lower, &upper, NSHeight(frame) / 2, NSMinYEdge);
	
	lower.size.height--;
	upper.origin.y++;
	upper.size.height--;
	
	[self addToolTipRect:upper owner:self userData:nil];
	[self addToolTipRect:lower owner:self userData:nil];
}

- (void)updateButtonStateWithEvent:(NSEvent *)event
{
	NSPoint locationInView = [self convertPoint:[event locationInWindow] fromView:nil];
	
	if (locationInView.y >= (NSHeight([self bounds])/2))
	{
		self.controlSize = NSRegularControlSize;
	}
	else
	{
		self.controlSize = NSSmallControlSize;
	}
}

- (void)mouseDown:(NSEvent *)event
{
	[self updateButtonStateWithEvent:event];
}

- (void)mouseDragged:(NSEvent *)event
{
	[self updateButtonStateWithEvent:event];
}

- (void)mouseUp:(NSEvent *)event
{
	[self.delegate sizeSelector:self selectedSize:self.controlSize];
}

- (void)setControlSize:(NSControlSize)aSize
{
	if (_controlSize != aSize) {
		_controlSize = aSize;
		[self setNeedsDisplay:YES];
	}
}

- (void)drawRect:(NSRect)rect {
	NSImage *image = (self.controlSize == NSRegularControlSize ? _bigImage : _smallImage);
	[image drawInRect:[self bounds] fromRect:(NSRect){NSZeroPoint, [image size]} operation:NSCompositeCopy fraction:1];
}

@end
