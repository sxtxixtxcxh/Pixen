//
//  PXToolButtonCell.m
//  Pixen
//
//  Created by Andy Matuschak on 7/18/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXToolButtonCell.h"


@implementation PXToolButtonCell

- (void)dealloc
{
	[glass release];
	[glassHighlighted release];
	[super dealloc];
}

- (void)setupImages
{
	if (glass && glassHighlighted) { return; }
	glass = [[NSImage imageNamed:@"glass"] retain];
	if ([NSColor currentControlTint] == NSGraphiteControlTint)
		glassHighlighted = [[NSImage imageNamed:@"glass-h-graphite"] retain];
	else
		glassHighlighted = [[NSImage imageNamed:@"glass-h"] retain];
	glassDivider = [[NSImage imageNamed:@"glass-d"] retain];
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view
{
	[self setupImages];
	NSImage *drawingImage = ([self isHighlighted] || [self state] == NSOnState) ? glassHighlighted : glass;
	[drawingImage setFlipped:[view isFlipped]];
	[drawingImage drawInRect:frame fromRect:NSMakeRect(0, 0, [drawingImage size].width, [drawingImage size].height) operation:NSCompositeCopy fraction:1.0];
	[[NSColor grayColor] set];
	[NSBezierPath setDefaultLineWidth:1];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(frame)-0.5, NSMinY(frame)) toPoint:NSMakePoint(NSMaxX(frame)-0.5, NSMaxY(frame))];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(frame), NSMinY(frame)-0.5) toPoint:NSMakePoint(NSMaxX(frame), NSMinY(frame)-0.5)];
	BOOL oldFlipped = [[self image] isFlipped];
	[[self image] setFlipped:[view isFlipped]];
	[[self image] drawInRect:NSMakeRect(NSMinX(frame) + ((NSWidth(frame) - [[self image] size].width) / 2), NSMinY(frame) + ((NSHeight(frame) - [[self image] size].height) / 2), [[self image] size].width, [[self image] size].height)
					fromRect:NSMakeRect(0, 0, [[self image] size].width, [[self image] size].height)
				   operation:NSCompositeSourceOver
					fraction:1];
	[[self image] setFlipped:oldFlipped];
}

@end
