//
//  PXPreviewBezelView.m
//  Pixen-XCode
//
//  Created by Andy Matuschak on 5/7/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXPreviewBezelView.h"

#import <QuartzCore/QuartzCore.h>
#import "NSBezierPath+PXRoundedRectangleAdditions.h"

@implementation PXPreviewBezelView

@synthesize opacity = alpha, delegate;

+ (id)defaultAnimationForKey:(NSString *)key
{
	if ([key isEqualToString:@"opacity"]) {
		CABasicAnimation *anim = [CABasicAnimation animation];
		anim.duration = 0.25f;
		
		return anim;
	}
	
	return [super defaultAnimationForKey:key];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (void)setOpacity:(CGFloat)opacity {
	if (alpha != opacity) {
		alpha = opacity;
		[self setNeedsDisplay:YES];
	}
}

- (void)dealloc
{
	[menu release];
	[super dealloc];
}

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		menu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"PXPreviewBezelMenu", @"PXPreviewBezelMenu")];
		[[menu addItemWithTitle:NSLocalizedString(@"Size To...", @"Size To...") action:@selector(sizeTo:) keyEquivalent:@""] setTarget:delegate];
		
		[menu addItem:[NSMenuItem separatorItem]];
		
		[[menu addItemWithTitle:@"50%" action:@selector(sizeToSenderTitlePercent:) keyEquivalent:@""] setTarget:delegate];
		[[menu addItemWithTitle:@"100%" action:@selector(sizeToSenderTitlePercent:) keyEquivalent:@""] setTarget:delegate];
		[[menu addItemWithTitle:@"200%" action:@selector(sizeToSenderTitlePercent:) keyEquivalent:@""] setTarget:delegate];
		[[menu addItemWithTitle:@"400%" action:@selector(sizeToSenderTitlePercent:) keyEquivalent:@""] setTarget:delegate];
		
		[menu addItem:[NSMenuItem separatorItem]];
		
		[[menu addItemWithTitle:NSLocalizedString(@"Set Background...", @"Set Background...") action:@selector(setBackground:) keyEquivalent:@""] setTarget:delegate];
	}
	return self;
}

- (void)drawCapsuleInRect:(NSRect)rect withFillColor:(NSColor *)fillColor outlineColor:(NSColor *)outlineColor
{
	NSRect frame = rect;
	NSBezierPath *path = [NSBezierPath bezierPath];
	// is this correct?
	[path appendBezierPathWithOvalInRect:NSInsetRect(NSMakeRect(NSMinX(frame), NSMinY(frame), NSHeight(frame), NSHeight(frame)), 1, 1)];
	[path appendBezierPathWithOvalInRect:NSInsetRect(NSMakeRect(NSMaxX(frame) - NSHeight(frame), NSMinY(frame), NSHeight(frame), NSHeight(frame)), 1, 1)];
	[path appendBezierPathWithRect:NSInsetRect(NSMakeRect(NSMinX(frame) + NSHeight(frame)/2, NSMinY(frame), NSWidth(frame) - NSHeight(frame), NSHeight(frame)), 1, 1)];
	[path setLineWidth:2];
	[outlineColor set];
	[path stroke];
	[fillColor set];
	[path fill];
}

- (void)mouseDown:(NSEvent *)event
{
	[NSMenu popUpContextMenu:menu withEvent:event forView:self];
}

- (void)drawRect:(NSRect)rect {
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(1, 1, 100, 100) cornerRadius:7];
	[[[NSColor lightGrayColor] colorWithAlphaComponent:alpha*.75] set];
	[path fill];
	[[[NSColor darkGrayColor] colorWithAlphaComponent:alpha] set];
	[path stroke];
	
	[[NSImage imageNamed:NSImageNameActionTemplate] drawInRect:NSMakeRect(4, 3, 12, 12)
													  fromRect:NSZeroRect
													 operation:NSCompositeSourceOver
													  fraction:alpha];
}

@end
