//
//  PXCanvasResizeView.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXCanvasResizeView.h"

#import <math.h>

@implementation PXCanvasResizeView {
	NSPoint _position;
	NSAffineTransform *_scaleTransform;
}

@synthesize backgroundColor = _backgroundColor, cachedImage = _cachedImage;
@synthesize newImageSize = _newSize, oldImageSize = _oldSize;

@dynamic leftOffset, topOffset;

- (void)awakeFromNib
{
	self.cachedImage = [NSImage imageNamed:@"greybox"];
	_scaleTransform = [[NSAffineTransform alloc] init];
	
	[self setBackgroundColor:[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:0]];
}

- (void)dealloc
{
	[_backgroundColor release];
	[_scaleTransform release];
	[_cachedImage release];
	
	[super dealloc];
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
	NSRect newRect = NSMakeRect(0, 0, _newSize.width, _newSize.height); 
	// Find the old size of the canvas
	NSRect oldRect = NSMakeRect(_position.x, _newSize.height-(_oldSize.height-(_position.y*-1)), _oldSize.width, _oldSize.height); 
	// Find the size we need to display in the view
	NSSize maxSize = NSMakeSize(MAX(_newSize.width, _oldSize.width), MAX(_newSize.height, _oldSize.height)); 
	NSSize frameSize = [self frame].size;
	
	// Find the scaling factor by looking at the rect that contains both the new size
	// and old size, then scaling it to fit our frame
	float scale = 1.0f / MAX(maxSize.height / frameSize.height, maxSize.width / frameSize.width); 
	
	oldRect.origin.x = round(oldRect.origin.x);
	oldRect.origin.y = round(oldRect.origin.y);
	
	[_scaleTransform release];
	// transform the image-pixel scale to screen-pixel scale
	_scaleTransform = [[NSAffineTransform transform] retain]; 
	[_scaleTransform scaleBy:scale];
	
	newRect = [self applyTransformation:_scaleTransform toRect:newRect]; // transform our rects
	oldRect = [self applyTransformation:_scaleTransform toRect:oldRect];
	
	NSAffineTransform *translateTransform = [NSAffineTransform transform];
	// center the view on the new frame
	[translateTransform translateXBy:(frameSize.width - NSWidth(newRect)) / 2 yBy:(frameSize.height - NSHeight(newRect)) / 2]; 
	
	// transform the rects again
	newRect = [self applyTransformation:translateTransform toRect:newRect];
	oldRect = [self applyTransformation:translateTransform toRect:oldRect];
	[[NSColor whiteColor] set];
	NSRectFillUsingOperation(newRect, NSCompositeCopy);
	NSRectFillUsingOperation(oldRect, NSCompositeCopy);
	[_backgroundColor set];
	NSRectFillUsingOperation(newRect, NSCompositeSourceOver);
	[[NSColor whiteColor] set];
	NSRectFillUsingOperation(NSIntersectionRect(newRect, oldRect), NSCompositeCopy);
	[_cachedImage drawInRect:oldRect 
					fromRect:NSMakeRect(0, 0, [_cachedImage size].width, [_cachedImage size].height)
				   operation:NSCompositeSourceOver
					fraction:1.0f]; // draw the image in the old frame
	[[NSColor blackColor] set];
	[NSBezierPath strokeRect:oldRect]; // draw an outline around the image
	
	NSBezierPath *canvasOutline = [NSBezierPath bezierPathWithRect:newRect];
	CGFloat dashed[2] = {3, 3};
	[canvasOutline setLineDash:dashed count:2 phase:0];
	[canvasOutline stroke]; // draw an outline around the canvas
	[canvasOutline setLineDash:dashed count:2 phase:3];
	[[NSColor whiteColor] set];
	[canvasOutline stroke]; // dash white and black
}

- (NSPoint)resultPosition
{
	NSPoint roundedPosition = _position;
	roundedPosition.x = round(roundedPosition.x);
	roundedPosition.y = round((_newSize.height-_oldSize.height)-roundedPosition.y);
	return roundedPosition;
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
		_position = NSMakePoint(0,0);
		
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

- (void)setBackgroundColor:(NSColor *)color
{
	if (_backgroundColor != color) {
		[_backgroundColor release];
		_backgroundColor = [color retain];
		
		[self setNeedsDisplay:YES];
	}
}

- (void)mouseUp:(NSEvent *)event
{
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event
{
	//FIXME: this is kind of clumsy, doesn't move enough
	NSAffineTransform *affineTransform = [_scaleTransform copy];
	[affineTransform invert];
	
	NSPoint deltaVector = [affineTransform transformPoint:NSMakePoint([event deltaX], [event deltaY])];
	[affineTransform release];
	
	[self setLeftOffset:[self leftOffset] + deltaVector.x];
	[self setTopOffset:[self topOffset] + deltaVector.y];
	[self setNeedsDisplay:YES];
}

- (void)keyDown:(NSEvent *)event
{
	NSString *characters = [event charactersIgnoringModifiers];
	NSPoint deltaVector = NSMakePoint(0, 0);
	
	if ([characters characterAtIndex:0] == NSUpArrowFunctionKey) {
		deltaVector.y = 1;
	} else if ([characters characterAtIndex:0] == NSDownArrowFunctionKey) {
		deltaVector.y = -1;
	} else if ([characters characterAtIndex:0] == NSRightArrowFunctionKey) {
		deltaVector.x = 1;
	} else if ([characters characterAtIndex:0] == NSLeftArrowFunctionKey) {
		deltaVector.x = -1;
	} else {
		[super keyDown:event];
		return;
	}
	
	if ([event modifierFlags] & NSShiftKeyMask) {
		deltaVector.x *= 10;
		deltaVector.y *= 10;
	}
	
	[self setLeftOffset:[self leftOffset] + deltaVector.x];
	[self setTopOffset:[self topOffset] - deltaVector.y];
	[self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (CGFloat)leftOffset;
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

- (CGFloat)topOffset;
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

- (CGFloat)bottomOffset;
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

- (CGFloat)rightOffset;
{
	return -1 * _position.x;
}

- (void)setRightOffset:(CGFloat)nv
{
	[self willChangeValueForKey:@"leftOffset"];
	_position.x = -1*nv;
	[self didChangeValueForKey:@"leftOffset"];
	[self setNeedsDisplay:YES];
}

@end
