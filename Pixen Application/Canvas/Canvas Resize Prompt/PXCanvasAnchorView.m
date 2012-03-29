//
//  PXCanvasAnchorView.m
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "PXCanvasAnchorView.h"

@implementation PXCanvasAnchorView

#define BOX 48.0f
#define MARGIN 1.0f
#define WIDTH (BOX + MARGIN)

#define ROWS 3

@synthesize anchor = _anchor;

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.anchor = PXCanvasAnchorCenter;
	}
	return self;
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)setAnchor:(PXCanvasAnchor)anchor
{
	if (_anchor != anchor) {
		_anchor = anchor;
		
		[self setNeedsDisplay:YES];
	}
}

- (NSRect)rectForCurrentAnchor
{
	int r, c;
	
	switch (_anchor) {
		case PXCanvasAnchorTopLeft:
			r = 0, c = 0;
			break;
		case PXCanvasAnchorTopCenter:
			r = 0, c = 1;
			break;
		case PXCanvasAnchorTopRight:
			r = 0, c = 2;
			break;
		case PXCanvasAnchorCenterLeft:
			r = 1, c = 0;
			break;
		case PXCanvasAnchorCenter:
			r = 1, c = 1;
			break;
		case PXCanvasAnchorCenterRight:
			r = 1, c = 2;
			break;
		case PXCanvasAnchorBottomLeft:
			r = 2, c = 0;
			break;
		case PXCanvasAnchorBottomCenter:
			r = 2, c = 1;
			break;
		case PXCanvasAnchorBottomRight:
			r = 2, c = 2;
			break;
		default:
			r = 1, c = 1;
			break;
	}
	
	return NSMakeRect(1.0f + c * WIDTH, 1.0f + r * WIDTH, BOX, BOX);
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	int r = floorf((location.y - 1.0f) / BOX);
	int c = floorf((location.x - 1.0f) / BOX);
	
	self.anchor = r * ROWS + c;
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect rect = [self bounds];
	
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	
	[[NSColor controlShadowColor] set];
	NSFrameRect(rect);
	
	for (CGFloat x = 0.0f; x < NSWidth(rect); x += WIDTH) {
		NSRectFill(NSMakeRect(x, 0.0f, 1.0f, NSHeight(rect)));
	}
	
	for (CGFloat y = 0.0f; y < NSHeight(rect); y += WIDTH) {
		NSRectFill(NSMakeRect(0.0f, y, NSWidth(rect), 1.0f));
	}
	
	NSRect iconRect = [self rectForCurrentAnchor];
	
	[[NSColor selectedControlColor] set];
	NSRectFill(iconRect);
	
	NSImage *icon = [NSImage imageNamed:@"Pixen128"];
	[icon drawInRect:iconRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f respectFlipped:YES hints:nil];
}

- (NSPoint)topLeftPositionWithOldSize:(NSSize)size newSize:(NSSize)newSize
{
	NSPoint position;
	
	switch (_anchor) {
		case PXCanvasAnchorTopLeft:
			position = NSMakePoint(0.0f, newSize.height - size.height);
			break;
		case PXCanvasAnchorTopCenter:
			position = NSMakePoint(floorf((newSize.width - size.width) / 2), newSize.height - size.height);
			break;
		case PXCanvasAnchorTopRight:
			position = NSMakePoint(newSize.width - size.width, newSize.height - size.height);
			break;
		case PXCanvasAnchorCenterLeft:
			position = NSMakePoint(0.0f, floorf((newSize.height - size.height) / 2));
			break;
		case PXCanvasAnchorCenter:
			position = NSMakePoint(floorf((newSize.width - size.width) / 2), floorf((newSize.height - size.height) / 2));
			break;
		case PXCanvasAnchorCenterRight:
			position = NSMakePoint(newSize.width - size.width, floorf((newSize.height - size.height) / 2));
			break;
		case PXCanvasAnchorBottomLeft:
			position = NSZeroPoint;
			break;
		case PXCanvasAnchorBottomCenter:
			position = NSMakePoint(floorf((newSize.width - size.width) / 2), 0.0f);
			break;
		case PXCanvasAnchorBottomRight:
			position = NSMakePoint(newSize.width - size.width, 0.0f);
			break;
		default:
			position = NSZeroPoint;
			break;
	}
	
	return position;
}

@end
