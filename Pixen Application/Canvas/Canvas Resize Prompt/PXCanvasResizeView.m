//
//  PXCanvasResizeView.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasResizeView.h"

#import <math.h>

@implementation PXCanvasResizeView

//FIXME: this stuff should use the canvas's mainBackground to draw the resize area; the matte color won't show up very well otherwise

@synthesize backgroundColor = _backgroundColor, cachedImage = _cachedImage;
@synthesize newImageSize = _newSize, oldImageSize = _oldSize;

@dynamic leftOffset, topOffset, bottomOffset, rightOffset;

- (void)dealloc
{
	[_backgroundColor release];
	[_scaleTransform release];
	[_cachedImage release];
	
	[super dealloc];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)awakeFromNib
{
	_scaleTransform = [[NSAffineTransform alloc] init];
	
	self.backgroundColor = [NSColor colorWithDeviceRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
}

- (NSRect)applyTransformation:(NSAffineTransform *)transform toRect:(NSRect)rect
{
	NSRect newRect;
	newRect.size = [transform transformSize:rect.size];
	newRect.origin = [transform transformPoint:rect.origin];
	
	return newRect;
}

- (void)drawRect:(NSRect)rect
{
	// Find the new size of the canvas
	NSRect newRect = NSMakeRect(0.0f, 0.0f, _newSize.width, _newSize.height);
	
	// Find the old size of the canvas
	NSRect oldRect = NSMakeRect(_position.x, _newSize.height - (_oldSize.height - (_position.y * -1)), _oldSize.width, _oldSize.height);
	
	// Find the size we need to display in the view
	NSSize maxSize = NSMakeSize(MAX(_newSize.width, _oldSize.width), MAX(_newSize.height, _oldSize.height));
	NSSize viewSize = [self bounds].size;
	
	// Find the scaling factor by looking at the rect that contains both the new size
	// and old size, then scaling it to fit our frame
	CGFloat scale = 1.0f / MAX(maxSize.height / viewSize.height, maxSize.width / viewSize.width);
	
	[_scaleTransform release];
	
	// transform the image-pixel scale to screen-pixel scale
	_scaleTransform = [[NSAffineTransform transform] retain];
	[_scaleTransform scaleBy:scale];
	
	newRect = [self applyTransformation:_scaleTransform toRect:newRect]; // transform our rects
	oldRect = [self applyTransformation:_scaleTransform toRect:oldRect];
	
	// center the view on the new frame
	NSAffineTransform *translateTransform = [NSAffineTransform transform];
	[translateTransform translateXBy:(viewSize.width - NSWidth(newRect)) / 2 yBy:(viewSize.height - NSHeight(newRect)) / 2];
	
	// transform the rects again
	newRect = NSIntegralRect([self applyTransformation:translateTransform toRect:newRect]);
	oldRect = NSIntegralRect([self applyTransformation:translateTransform toRect:oldRect]);
	
	[[NSColor whiteColor] set];
	NSRectFillUsingOperation(newRect, NSCompositeCopy);
	NSRectFillUsingOperation(oldRect, NSCompositeCopy);
	
	[_backgroundColor set];
	NSRectFillUsingOperation(newRect, NSCompositeSourceOver);
	
	[[NSColor whiteColor] set];
	NSRectFillUsingOperation(NSIntersectionRect(newRect, oldRect), NSCompositeCopy);
	
	[_cachedImage drawInRect:oldRect
					fromRect:NSMakeRect(0.0f, 0.0f, [_cachedImage size].width, [_cachedImage size].height)
				   operation:NSCompositeSourceOver
					fraction:1.0f]; // draw the image in the old frame
	
	[[NSColor darkGrayColor] set];
	NSFrameRect(oldRect);
	
	NSAffineTransform *pixelTransform = [NSAffineTransform transform];
	[pixelTransform translateXBy:0.5f yBy:0.5f]; // don't draw half-pixels
	
	newRect.size.width -= 1.0f;
	newRect.size.height -= 1.0f;
	
	NSBezierPath *canvasOutline = [NSBezierPath bezierPathWithRect:newRect];
	[canvasOutline transformUsingAffineTransform:pixelTransform];
	
	CGFloat dashed[2] = { 3.0f, 3.0f };
	[canvasOutline setLineDash:dashed count:2 phase:0.0f];
	[canvasOutline stroke]; // draw an outline around the canvas
	
	[[NSColor whiteColor] set];
	[canvasOutline setLineDash:dashed count:2 phase:3.0f];
	[canvasOutline stroke]; // dash white and black
}

- (void)mouseDragged:(NSEvent *)event
{
	NSAffineTransform *affineTransform = [_scaleTransform copy];
	[affineTransform invert];
	
	NSPoint deltaVector = [affineTransform transformPoint:NSMakePoint([event deltaX], [event deltaY])];
	[affineTransform release];
	
	deltaVector.x = floor(deltaVector.x);
	deltaVector.y = floor(deltaVector.y);
	
	[self setLeftOffset:[self leftOffset] + deltaVector.x];
	[self setTopOffset:[self topOffset] + deltaVector.y];
}

- (void)mouseUp:(NSEvent *)event
{
	[self setNeedsDisplay:YES];
}

- (void)keyDown:(NSEvent *)event
{
	NSString *characters = [event charactersIgnoringModifiers];
	NSPoint deltaVector = NSZeroPoint;
	
	if ([characters characterAtIndex:0] == NSUpArrowFunctionKey) {
		deltaVector.y = 1.0f;
	}
	else if ([characters characterAtIndex:0] == NSDownArrowFunctionKey) {
		deltaVector.y = -1.0f;
	}
	else if ([characters characterAtIndex:0] == NSRightArrowFunctionKey) {
		deltaVector.x = 1.0f;
	}
	else if ([characters characterAtIndex:0] == NSLeftArrowFunctionKey) {
		deltaVector.x = -1.0f;
	}
	else {
		[super keyDown:event];
		return;
	}
	
	if ([event modifierFlags] & NSShiftKeyMask) {
		deltaVector.x *= 10.0f;
		deltaVector.y *= 10.0f;
	}
	
	[self setLeftOffset:[self leftOffset] + deltaVector.x];
	[self setTopOffset:[self topOffset] - deltaVector.y];
}

- (void)setBackgroundColor:(NSColor *)color
{
	if (_backgroundColor != color) {
		[_backgroundColor release];
		_backgroundColor = [color retain];
		
		[self setNeedsDisplay:YES];
	}
}

- (void)setCachedImage:(NSImage *)image
{
	if (_cachedImage != image) {
		[_cachedImage release];
		_cachedImage = [image retain];
		
		[self setNeedsDisplay:YES];
	}
}

- (void)setNewImageSize:(NSSize)size
{
	if (!NSEqualSizes(_newSize, size)) {
		_newSize = size;
		[self setNeedsDisplay:YES];
	}
}

- (void)setOldImageSize:(NSSize)size
{
	if (!NSEqualSizes(_oldSize, size)) {
		_oldSize = size;
		_position = NSMakePoint(0.0f, 0.0f);
		
		[self setNeedsDisplay:YES];
	}
}

- (CGFloat)leftOffset
{
	return _position.x;
}

- (void)setLeftOffset:(CGFloat)nx;
{
	[self willChangeValueForKey:@"rightOffset"];
	_position.x = nx;
	[self didChangeValueForKey:@"rightOffset"];
	[self setNeedsDisplay:YES];
}

- (CGFloat)topOffset
{
	return _position.y;
}

- (void)setTopOffset:(CGFloat)nv
{
	[self willChangeValueForKey:@"bottomOffset"];
	_position.y = nv;
	[self didChangeValueForKey:@"bottomOffset"];
	[self setNeedsDisplay:YES];
}

- (CGFloat)bottomOffset
{
	return -1 * _position.y;
}

- (void)setBottomOffset:(CGFloat)nv
{
	[self willChangeValueForKey:@"topOffset"];
	_position.y = -1 * nv;
	[self didChangeValueForKey:@"topOffset"];
	[self setNeedsDisplay:YES];
}

- (CGFloat)rightOffset
{
	return -1 * _position.x;
}

- (void)setRightOffset:(CGFloat)nv
{
	[self willChangeValueForKey:@"leftOffset"];
	_position.x = -1 * nv;
	[self didChangeValueForKey:@"leftOffset"];
	[self setNeedsDisplay:YES];
}

- (NSPoint)resultantPosition
{
	NSPoint roundedPosition = _position;
	roundedPosition.y = (_newSize.height - _oldSize.height) - roundedPosition.y;
	
	return roundedPosition;
}

@end
