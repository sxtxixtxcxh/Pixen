//
//  PXNSImageView.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXNSImageView.h"
#import "OSRectAdditions.h"

@implementation PXNSImageView

- (void)initialize
{
	functionalRect = NSZeroRect;
	shadow = [[NSShadow alloc] init];
	[shadow setShadowBlurRadius:4];
	[shadow setShadowOffset:NSMakeSize(0, -2)];
	[shadow setShadowColor:[NSColor colorWithDeviceWhite:0.2 alpha:1]];	
}

- (id)initWithFrame:(NSRect)rect
{
	self = [super initWithFrame:rect];
	[self initialize];
	return self;
}

- (void)mouseDown:(NSEvent *) event
{
	[[self superview] mouseDown:event];
}

- (void)rightMouseDown:(NSEvent *) event
{
	[[self superview] rightMouseDown:event];
}

- (void)mouseUp:(NSEvent *) event
{
	[[self superview] mouseUp:event];
}

- (void)rightMouseUp:(NSEvent *) event
{
	[[self superview] rightMouseUp:event];
}

- (void)mouseDragged:(NSEvent *) event
{
	[[self superview] mouseDragged:event];
}

- (void)rightMouseDragged:(NSEvent *) event
{
	[[self superview] rightMouseDragged:event];
}

- (void)awakeFromNib
{
	[self initialize];
}

- (NSSize)scaledSizeForImage:(NSImage *)image
{
	NSSize imageSize = [image size];
	NSSize viewSize = [self bounds].size;
	NSSize size;
	viewSize.width -= 8;
	viewSize.height -= 8;
	if (imageSize.width > imageSize.height)
	{
		if (imageSize.width > viewSize.width)
		{
			size.width = viewSize.width;
			size.height = ceilf(imageSize.height * (viewSize.width / imageSize.width));
		}
		else
			size = imageSize;
	}
	else
	{
		if (imageSize.height > viewSize.height)
		{
			size.height = viewSize.height;
			size.width = ceilf(imageSize.width * (viewSize.height / imageSize.height));
		}
		else
			size = imageSize;
	}
	return size;
}

- (void)setImage:(NSImage *)image
{
	[super setImage:image];
	functionalRect = OSCenterRectInRect((NSRect){NSZeroPoint, [image size]}, [self bounds], 4);	
	scaleFactor = [[self image] size].width / NSWidth(functionalRect);
}

- (NSRect)functionalRect
{
	return functionalRect;
}

- (void)drawRect:(NSRect)rect
{
	[NSGraphicsContext saveGraphicsState];
	// We'll create a blank clipped region to draw a shadow under; we don't want to shadow the image itself.
	[shadow set];
	NSEraseRect(functionalRect);
	[NSGraphicsContext restoreGraphicsState];
	
	NSRect inRect = NSIntersectionRect(rect, functionalRect);
	NSRect fromRect = NSOffsetRect(inRect, -NSMinX(functionalRect), -NSMinY(functionalRect));
	fromRect.origin.x *= scaleFactor;
	fromRect.origin.y *= scaleFactor;
	fromRect.size.width *= scaleFactor;
	fromRect.size.height *= scaleFactor;
	
	[[self image] drawInRect:inRect
					fromRect:fromRect
				   operation:NSCompositeSourceOver
					fraction:1];
}

- (void)setFunctionalRect:(NSRect)fr
{
	functionalRect = fr;
}

@end
