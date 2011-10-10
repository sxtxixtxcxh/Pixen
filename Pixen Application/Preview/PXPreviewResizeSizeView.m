//
//  PXPreviewResizeSizeView.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXPreviewResizeSizeView.h"

@implementation PXPreviewResizeSizeView {
	NSAttributedString *_scaleString;
}

- (id)initWithFrame:(NSRect)frame
{
	if ( ! ( self = [super initWithFrame:frame]))
		return nil;
	
	[self updateScale:0];
	
	return self;
}

- (void)dealloc
{
	[_scaleString release];
	[super dealloc];
}

- (BOOL)updateScale:(CGFloat)scale
{
	if (scale > 100000)
		return NO;
	
	[_scaleString release];
	_scaleString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d%%", (int)(scale * 100)]
												   attributes:[NSDictionary dictionaryWithObjectsAndKeys:
															   [NSFont fontWithName:@"Verdana" size:20.0f], NSFontAttributeName,
															   [NSColor blackColor], NSForegroundColorAttributeName,
															   nil]];
	
	[self setNeedsDisplay:YES];
	
	return YES;
}

- (void)drawRect:(NSRect)rect
{
	[[NSColor clearColor] set];
	NSRectFill([self frame]);
	NSRect frame = [self frame];
	NSBezierPath *background = [NSBezierPath bezierPath];
	NSPoint stringPoint = frame.origin;
	float x = NSMinX(frame), y = NSMinY(frame), width = NSWidth(frame), height = NSHeight(frame), maxX = NSMaxX(frame);
	if (height >= width) {
		[background appendBezierPathWithOvalInRect:frame];
	} else {
		NSRect leftSide = NSMakeRect(x, y, height, height);
		NSRect rightSide = NSMakeRect(maxX - height, y, height, height);
		NSRect middle = NSMakeRect(x + (height / 2.0f), y, width - height, height);
		NSRect topLeftCorner = NSMakeRect(x, y+(height/2), height/2, height/2);
		
		[background appendBezierPathWithOvalInRect:leftSide];
		[background appendBezierPathWithOvalInRect:rightSide];
		[background appendBezierPathWithRect:middle];
		
		[background appendBezierPathWithRect:topLeftCorner];
	}
	stringPoint.x += (width - [_scaleString size].width) / 2;
	stringPoint.y += (height - [_scaleString size].height) / 2 + [_scaleString size].height / 9;
	[[NSColor whiteColor] set];
	[background fill];
	[_scaleString drawAtPoint:stringPoint];
}

- (NSSize)scaleStringSize
{
	NSSize size = [_scaleString size];
	return NSMakeSize(size.width * 1.3, size.height);
}

@end
