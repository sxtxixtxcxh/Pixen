//
//  PXAnimationBackgroundView.m
//  Pixen
//
//  Created by Andy Matuschak on 10/16/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "OSLinearGradient.h"
#import "PXAnimationBackgroundView.h"

@implementation PXAnimationBackgroundView

- (void)awakeFromNib
{
	horizontalGradient = [[OSLinearGradient alloc] initWithStartColor:[NSColor blackColor] endColor:[NSColor colorWithCalibratedRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1]];
}

- (void)drawRect:(NSRect)rect {
	NSRect visibleRect = [self bounds];
	NSPoint start = NSMakePoint(NSMinX(visibleRect), NSMidY(visibleRect));
	NSPoint middle = NSMakePoint(NSMidX(visibleRect), NSMidY(visibleRect));
	NSPoint leftMiddle = middle;
	leftMiddle.x = floorf(leftMiddle.x - NSWidth(visibleRect)*0.2);
	NSPoint rightMiddle = middle;
	rightMiddle.x = floorf(rightMiddle.x + NSWidth(visibleRect)*0.2);
	NSPoint end = NSMakePoint(NSMaxX(visibleRect), NSMidY(visibleRect));
	
	[horizontalGradient drawFromPoint:start toPoint:leftMiddle inRect:rect];
	[horizontalGradient drawFromPoint:end toPoint:rightMiddle inRect:rect];
	
	[[NSColor colorWithCalibratedRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1] set];
	NSRectFill(NSMakeRect(leftMiddle.x, NSMinY(visibleRect), rightMiddle.x - leftMiddle.x, NSHeight(visibleRect)));
	
	NSRect lowerRect = visibleRect;
	lowerRect.size.height /= 2.0;
	
	[[NSColor whiteColor] set];
	NSRectFill(NSMakeRect(NSMinX([filmStrip frame])-1, 0, 1.5, NSHeight([self bounds])));	
	NSRectFill(NSMakeRect(NSMaxX([filmStrip frame]), 0, 1.5, NSHeight([self bounds])));
}

@end
