//
//  PXColorPickerColorWellCell.m
//  PXColorPicker
//
//  Created by Andy Matuschak on 7/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXColorPickerColorWellCell.h"
#import "NSBezierPath+PXRoundedRectangleAdditions.h"

@interface NSImage (PXTintedImage)
- (NSImage *)tintedImage;
@end

@implementation NSImage (PXTintedImage)
- (NSImage *)tintedImage
{	
	NSImage *tintImage = [[[NSImage alloc] initWithSize:[self size]] autorelease];
	[tintImage lockFocus];
	[[[NSColor blackColor] colorWithAlphaComponent:1] set];
	[[NSBezierPath bezierPathWithRect:(NSRect){NSZeroPoint, [self size]}] fill];
	[tintImage unlockFocus];
	
	NSImage *tintMaskImage = [[[NSImage alloc] initWithSize:[self size]] autorelease];
	[tintMaskImage lockFocus];
	[self compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
	[tintImage compositeToPoint:NSZeroPoint operation:NSCompositeSourceIn];
	[tintMaskImage unlockFocus];
	
	NSImage *newImage = [[[NSImage alloc] initWithSize:[self size]] autorelease];
	[newImage lockFocus];
	[self dissolveToPoint:NSZeroPoint fraction:0.6];
	[tintMaskImage compositeToPoint:NSZeroPoint operation:NSCompositeDestinationAtop];
	[newImage unlockFocus];
	return newImage;
}
@end

@implementation PXColorPickerColorWellCell

- init
{
	[super init];
	smallNewColorImage = [[NSImage imageNamed:@"newcolorsmall"] retain];
	bigNewColorImage = [[NSImage imageNamed:@"newcolorbig"] retain];
	return self;
}

- (void)dealloc
{
	[smallNewColorImage release];
	[bigNewColorImage release];
	[super dealloc];
}

- (void)drawColorSwatchWithFrame:(NSRect)rect inView:(NSView *)view
{
	// Draw that black/white alpha helper and use non-blind compositing. But only if we have to.
	if ([color alphaComponent] != 1)
	{
		BOOL flipped = [view isFlipped];
		NSPoint points[3];
		NSBezierPath *path = [NSBezierPath bezierPath];
		
		// First draw the black triangle, which covers the upper-left portion of the rect.
		points[0] = NSMakePoint(NSMinX(rect), (flipped) ? NSMinY(rect) : NSMaxY(rect));
		points[1] = NSMakePoint(NSMaxX(rect), (flipped) ? NSMinY(rect) : NSMaxY(rect));
		points[2] = NSMakePoint(NSMinX(rect), (flipped) ? NSMaxY(rect) : NSMinY(rect));
		[path appendBezierPathWithPoints:points count:3];
		[[NSColor blackColor] set];
		[path fill];
		
		// Now for the white triangle.
		points[0] = NSMakePoint(NSMaxX(rect), (flipped) ? NSMinY(rect) : NSMaxY(rect));
		points[1] = NSMakePoint(NSMaxX(rect), (flipped) ? NSMaxY(rect) : NSMinY(rect));
		points[2] = NSMakePoint(NSMinX(rect), (flipped) ? NSMaxY(rect) : NSMinY(rect));
		[path removeAllPoints];
		[path appendBezierPathWithPoints:points count:3];
		[[NSColor whiteColor] set];
		[path fill];
		
		// Now composite over the actual color.
		[color set];
		NSRectFillUsingOperation(rect, NSCompositeSourceOver);
	}
	else
	{
		// Nothing fancy's required; just paint the color.
		[color set];
		NSRectFill(rect);
	}
}

- (void)setState:(PXColorCelState)newState
{
	state = newState;
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)aView
{
	BOOL flipped = [aView isFlipped];
	[color set];
	if (index == -1)
	{
		NSImage *image = ([self controlSize] == NSRegularControlSize ? bigNewColorImage : smallNewColorImage);
		[image setFlipped:flipped];
		NSEraseRect(frame);
		if ([self isHighlighted])
		{
			image = [image tintedImage];
		}
		[image drawInRect:frame fromRect:(NSRect){NSZeroPoint, [image size]} operation:NSCompositeCopy fraction:1];
	}
	else
	{
		[self drawColorSwatchWithFrame:frame inView:aView];
	}
	
	// Exceuse me for my mdrfkr hardcoded numbers and ternary operators.
	[(state != PXNoToolColor ? [NSColor keyboardFocusIndicatorColor] : [[NSColor grayColor] colorWithAlphaComponent:0.5]) set];
	int fontSize = [NSFont systemFontSizeForControlSize:NSMiniControlSize];
	if (index > 9999)
		fontSize = floorf(fontSize * .85);
	NSAttributedString *badgeString = [[[NSAttributedString alloc] initWithString:(index == -1 ? @"new" : [NSString stringWithFormat:@"%d", index])
																	   attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:fontSize], NSFontAttributeName, nil]] autorelease];
	NSSize badgeSize = [badgeString size];	
	badgeSize.width += 6.5;
	badgeSize.height += 0;
	NSRect badgeRect = NSMakeRect(NSMaxX(frame) - badgeSize.width - 1.5, flipped ? NSMaxY(frame) - badgeSize.height - 2 : 2, badgeSize.width, badgeSize.height);
	if (state == PXNoToolColor)
	{
		NSFrameRectWithWidthUsingOperation(NSInsetRect(frame, 0, 0), 2, NSCompositeSourceOver);
	}
	else
	{
		if (!flipped)
			badgeRect.origin.y--;
		badgeRect.size.height+=2;
		badgeRect.size.width+=1.5;
	}
	
	int verticalTextOffset = (index > 9999) ? 1 : 2;	

	NSBezierPath *indexBadge = [NSBezierPath bezierPathWithRoundedRect:badgeRect cornerRadius:5 inCorners:flipped ? OSBottomLeftCorner : OSTopLeftCorner];
	if (state != PXNoToolColor)
	{
		[[NSGraphicsContext currentContext] saveGraphicsState];
		NSSetFocusRingStyle(NSFocusRingOnly);
		NSRectFill(frame);
		if ([self controlSize] == NSRegularControlSize)
		{
			[[NSBezierPath bezierPathWithRect:NSOffsetRect(badgeRect, -1, (flipped ? -1 : 1))] addClip];
			[indexBadge fill];
		}
		[[NSGraphicsContext currentContext] restoreGraphicsState];
	}
	
	if ([self controlSize] != NSRegularControlSize) { return; }
	
	if ((state != PXNoToolColor) && (state != PXSelectedColor))
	{
		NSString *activeTool;
		if (state == PXLeftToolColor) { activeTool = @"left"; }
		else if (state == PXRightToolColor) { activeTool = @"right"; }
		else { activeTool = @"both"; }
		NSAttributedString *activeToolString = [[[NSAttributedString alloc] initWithString:activeTool attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]], NSFontAttributeName, nil]] autorelease];
		NSSize stringSize = [activeToolString size];
		stringSize.width += 6.5;
		
		NSRect toolBadgeRect;
		NSRect toolClipRect;
		NSBezierPath *toolBadgePath = nil;
		NSPoint toolStringPoint = NSZeroPoint;
		switch (state)
		{
			case PXLeftToolColor:
				toolBadgeRect = NSMakeRect(NSMinX(frame), flipped ? NSMinY(frame) : NSMaxY(frame) - badgeSize.height - 2, stringSize.width, stringSize.height);
				toolClipRect = NSOffsetRect(toolBadgeRect, 1, (flipped ? 1 : -1));
				toolBadgePath = [NSBezierPath bezierPathWithRoundedRect:toolBadgeRect cornerRadius:5 inCorners:flipped ? OSTopRightCorner : OSBottomRightCorner];
				toolStringPoint = NSMakePoint(NSMinX(frame) + 3, flipped ? NSMinY(frame) : NSMaxY(frame) - badgeSize.height - verticalTextOffset);
				break;
			case PXRightToolColor:
				toolBadgeRect = NSMakeRect(NSMaxX(frame) - stringSize.width, flipped ? NSMinY(frame) : NSMaxY(frame) - badgeSize.height - 2, stringSize.width, stringSize.height);
				toolClipRect = NSOffsetRect(toolBadgeRect, -1, (flipped ? 1 : -1));
				toolBadgePath = [NSBezierPath bezierPathWithRoundedRect:toolBadgeRect cornerRadius:5 inCorners:flipped ? OSTopLeftCorner : OSBottomLeftCorner];
				toolStringPoint = NSMakePoint(NSMaxX(frame) - stringSize.width + 4, flipped ? NSMinY(frame) : NSMaxY(frame) - badgeSize.height - verticalTextOffset);				
				break;
			case PXBothToolColor:
				toolBadgeRect = NSMakeRect(NSMinX(frame), flipped ? NSMinY(frame) : NSMaxY(frame) - badgeSize.height - 2, NSWidth(frame), stringSize.height);
				toolClipRect = NSOffsetRect(toolBadgeRect, 0, (flipped ? 1 : -1));
				toolClipRect.origin.x++;
				toolClipRect.size.width-=2;
				toolBadgePath = [NSBezierPath bezierPathWithRect:toolBadgeRect];
				toolStringPoint = NSMakePoint(NSMidX(frame) - ([activeToolString size].width / 2), flipped ? NSMinY(frame) : NSMaxY(frame) - badgeSize.height - verticalTextOffset);				
				break;
			default:
				break;
		}
		[[NSGraphicsContext currentContext] saveGraphicsState];
		NSSetFocusRingStyle(NSFocusRingOnly);
		[[NSBezierPath bezierPathWithRect:toolClipRect] addClip];
		[toolBadgePath fill];
		[[NSGraphicsContext currentContext] restoreGraphicsState];
		[toolBadgePath fill];
		[activeToolString drawAtPoint:toolStringPoint];
	}
	
	[(state != PXNoToolColor ? [NSColor keyboardFocusIndicatorColor] : [[NSColor grayColor] colorWithAlphaComponent:0.5]) set];
	[indexBadge fill];
	
	[badgeString drawAtPoint:NSMakePoint(NSMaxX(frame) - badgeSize.width + 3, flipped ? NSMaxY(frame) - badgeSize.height - verticalTextOffset : verticalTextOffset)];
}

- (int)index
{
	return index;
}

- (void)setIndex:(int)newIndex
{
	index = newIndex;
}

- (NSColor *)color
{
	return color;
}

- (void)setColor:(NSColor *)newColor
{
	color = newColor;
}

@end
