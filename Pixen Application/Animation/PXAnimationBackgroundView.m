//
//  PXAnimationBackgroundView.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXAnimationBackgroundView.h"
		
@implementation PXAnimationBackgroundView

@synthesize filmStrip = _filmStrip;

- (void)awakeFromNib
{
	NSColor *endColor = [NSColor colorWithDeviceRed:51.0/255.0f
											  green:51.0/255.0f
											   blue:51.0/255.0f
											  alpha:1.0f];
	
	_horizontalGradient = [[NSGradient alloc] initWithStartingColor:[NSColor blackColor]
														endingColor:endColor];
}

- (void)drawRect:(NSRect)rect {
	NSRect visibleRect = [self bounds];	
	NSPoint middle = NSMakePoint(NSMidX(visibleRect), NSMidY(visibleRect));
	CGFloat leftMiddle = floorf(middle.x - NSWidth(visibleRect)*0.2f);
	CGFloat rightMiddle = floorf(middle.x + NSWidth(visibleRect)*0.2f);
	
	[_horizontalGradient drawInRect:NSMakeRect(NSMinX(visibleRect), NSMinY(visibleRect), leftMiddle - NSMinX(visibleRect), NSHeight(visibleRect))
							  angle:0.0f];
	
	[_horizontalGradient drawInRect:NSMakeRect(rightMiddle, NSMinY(visibleRect), NSWidth(visibleRect) - rightMiddle, NSHeight(visibleRect))
							  angle:180.0f];
	
	[[NSColor colorWithDeviceRed:51.0/255.0f green:51.0/255.0f blue:51.0/255.0f alpha:1.0f] set];
	NSRectFill(NSMakeRect(leftMiddle, NSMinY(visibleRect), rightMiddle - leftMiddle, NSHeight(visibleRect)));
	
	NSRect lowerRect = visibleRect;
	lowerRect.size.height /= 2.0f;
	
	[[NSColor whiteColor] set];
	NSRectFill(NSMakeRect(NSMinX([self.filmStrip frame]) - 1.0f, 0.0f, 1.5f, NSHeight([self bounds])));
	NSRectFill(NSMakeRect(NSMaxX([self.filmStrip frame]), 0.0f, 1.5f, NSHeight([self bounds])));
}

@end
