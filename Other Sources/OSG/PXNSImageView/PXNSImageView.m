//  PXNSImageView.m
//  Pixen-XCode
//
// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "PXNSImageView.h"

@implementation PXNSImageView

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
	functionalRect = NSZeroRect;
}

- (void)dealloc
{
	[shadow release];
	[super dealloc];
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
	NSSize viewSize = [self bounds].size;
	viewSize.width -= 8;
	viewSize.height -= 8;
	functionalRect.origin = NSZeroPoint;
	functionalRect.size = [self scaledSizeForImage:image];
	if (NSWidth(functionalRect) < viewSize.width)
		functionalRect.origin.x = ceilf((viewSize.width / 2) - (NSWidth(functionalRect) / 2));
	if (NSHeight(functionalRect) < viewSize.height)
		functionalRect.origin.y = ceilf((viewSize.height / 2) - (NSHeight(functionalRect) / 2));
	functionalRect.origin.x += 4;
	functionalRect.origin.y += 4;
	
	scaleFactor = [[self image] size].width / NSWidth(functionalRect);
}

- (NSRect)functionalRect
{
	return functionalRect;
}

- (void)drawRect:(NSRect)rect
{
	[NSGraphicsContext saveGraphicsState];
	if (shadow == nil)
	{
		shadow = [[NSShadow alloc] init];
		[shadow setShadowBlurRadius:4];
		[shadow setShadowOffset:NSMakeSize(0, -2)];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.2 alpha:1]];
	}
	[shadow set];
	NSEraseRect(functionalRect);
	[NSGraphicsContext restoreGraphicsState];
	
	//NSLog(@"Updating image view in rect: %fx%fx%fx%f", NSMinX(rect), NSMinY(rect), NSWidth(rect), NSHeight(rect));
	//NSLog(@"Scale factor: %f", scaleFactor);
	//NSLog(@"Functional rect: %fx%fx%fx%f", NSMinX(functionalRect), NSMinY(functionalRect), NSWidth(functionalRect), NSHeight(functionalRect));

	NSRect inRect = NSIntersectionRect(rect, functionalRect);
	NSRect fromRect = NSOffsetRect(inRect, -NSMinX(functionalRect), -NSMinY(functionalRect));
	fromRect.origin.x *= scaleFactor;
	fromRect.origin.y *= scaleFactor;
	fromRect.size.width *= scaleFactor;
	fromRect.size.height *= scaleFactor;
	//NSLog(@"In rect: %fx%fx%fx%f", NSMinX(inRect), NSMinY(inRect), NSWidth(inRect), NSHeight(inRect));
	//NSLog(@"From rect: %fx%fx%fx%f", NSMinX(fromRect), NSMinY(fromRect), NSWidth(fromRect), NSHeight(fromRect));
	
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
