//
//  OSPlasticButtonCell.m
//  Pixen
// 
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "OSPlasticButtonCell.h"
#import "OSRectAdditions.h"

@implementation OSPlasticButtonCell

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(redraw:)
												 name:NSWindowDidBecomeKeyNotification
											   object:[[self controlView] window]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(redraw:)
												 name:NSWindowDidResignKeyNotification
											   object:[[self controlView] window]];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)redraw:(id)sender
{
	[[self controlView] setNeedsDisplay:YES];
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view
{
	NSArray *colors = nil;
	
	if ([self isHighlighted] || [self state] == NSOnState) {
		if ([[view window] isKeyWindow]) {
			colors = [NSArray arrayWithObjects:
					  [NSColor colorWithCalibratedRed:0.58f green:0.86f blue:0.98f alpha:1.0f],
					  [NSColor colorWithCalibratedRed:0.42f green:0.68f blue:0.90f alpha:1.0f],
					  [NSColor colorWithCalibratedRed:0.59f green:0.75f blue:0.92f alpha:1.0f],
					  [NSColor colorWithCalibratedRed:0.56f green:0.70f blue:0.90f alpha:1.0f], nil];
		}
		else {
			colors = [NSArray arrayWithObjects:
					  [NSColor colorWithCalibratedRed:0.80f green:0.80f blue:0.80f alpha:1.0f],
					  [NSColor colorWithCalibratedRed:0.70f green:0.70f blue:0.70f alpha:1.0f],
					  [NSColor colorWithCalibratedRed:0.77f green:0.77f blue:0.77f alpha:1.0f],
					  [NSColor colorWithCalibratedRed:0.75f green:0.75f blue:0.75f alpha:1.0f], nil];
		}
	}
	else {
		colors = [NSArray arrayWithObjects:
				  [NSColor colorWithCalibratedRed:0.95f green:0.95f blue:0.95f alpha:1.0f],
				  [NSColor colorWithCalibratedRed:0.85f green:0.85f blue:0.85f alpha:1.0f],
				  [NSColor colorWithCalibratedRed:0.92f green:0.92f blue:0.92f alpha:1.0f],
				  [NSColor colorWithCalibratedRed:0.90f green:0.90f blue:0.90f alpha:1.0f], nil];
	}
	
	CGFloat locations[] = { 0.0f, 11.5f/23, 11.5f/23, 1.0f };
	
	NSGradient *gradient = [[NSGradient alloc] initWithColors:colors atLocations:locations colorSpace:[NSColorSpace genericRGBColorSpace]];
	
	NSRect gradientRect = frame;
	gradientRect.size.height -= 1.0f;
	
	[gradient drawInRect:gradientRect angle:270];
	
	[[NSColor grayColor] set];
	[NSBezierPath setDefaultLineWidth:1];
	
	if (frame.origin.x != 0)
		[NSBezierPath strokeLineFromPoint:NSMakePoint(frame.origin.x+0.5, frame.origin.y)
								  toPoint:NSMakePoint(frame.origin.x+0.5, frame.origin.y+frame.size.height)];
	if (frame.origin.y != 0)
		[NSBezierPath strokeLineFromPoint:NSMakePoint(frame.origin.x, frame.origin.y+0.5)
								  toPoint:NSMakePoint(frame.origin.x+frame.size.width,frame.origin.y+0.5)];
	
	BOOL oldFlipped = [[self image] isFlipped];
	[[self image] setFlipped:[view isFlipped]];
	NSRect centeredFrame = OSCenterRectInRect((NSRect){NSZeroPoint, [[self image] size]}, frame, 2);
	[[self image] drawInRect:centeredFrame
					fromRect:(NSRect){NSZeroPoint, [[self image] size]}
				   operation:NSCompositeSourceOver
					fraction:1];
	[[self image] setFlipped:oldFlipped];
}

@end
