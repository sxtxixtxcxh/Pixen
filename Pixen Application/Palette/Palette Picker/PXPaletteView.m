//
//  PXPaletteView.m
//  Pixen
//
//  Copyright 2011-2012 Pixen. All rights reserved.
//

#import "PXPaletteView.h"

#import "PXPaletteColorLayer.h"

@implementation PXPaletteView

const CGFloat viewMargin = 1.0f;

@synthesize enabled, highlightEnabled, controlSize, palette, delegate;

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self setEnabled:YES];
		
		selectionIndex = NSNotFound;
		palette = NULL;
		controlSize = NSRegularControlSize;
		highlightEnabled = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(paletteChanged:)
													 name:PXPaletteChangedNotificationName
												   object:nil];
		
		[self registerForDraggedTypes:[NSArray arrayWithObject:NSPasteboardTypeColor]];
	}
	return self;
}

- (void)awakeFromNib
{
	[self setupLayer];
}

- (void)setupLayer
{
	CALayer *rootLayer = [self layer];
	rootLayer.geometryFlipped = YES;
	rootLayer.layoutManager = self;
	
	[self setNeedsRetile];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)size
{
	width = (controlSize == NSRegularControlSize ? 32 : 16) + viewMargin;
	height = width;
	columns = NSWidth([self bounds]) / width;
	rows = palette ? ceilf((float)(([palette colorCount])) / columns) : 0;
}

- (void)viewDidEndLiveResize
{
	[self size];
	[self.layer setNeedsLayout];
}

- (void)layoutSublayersOfLayer:(CALayer *)superlayer
{
	for (CALayer *layer in [superlayer sublayers]) {
		if (![layer isKindOfClass:[PXPaletteColorLayer class]])
			continue;
		
		NSUInteger n = [ (PXPaletteColorLayer *) layer index];
		
		NSUInteger i = n % columns;
		NSUInteger j = n / columns;
		
		layer.frame = CGRectMake(viewMargin*2 + i*width, viewMargin*2 + j*height, width - viewMargin*2, height - viewMargin*2);
	}
}

- (void)retile
{
	selectionIndex = NSNotFound;
	
	[self size];
	[self setFrameSize:NSMakeSize(NSWidth([[self superview] bounds]), MAX(rows * height + viewMargin*2, NSHeight([[self superview] bounds])))];
	
	self.layer.sublayers = nil;
	
	if (!palette)
		return;
	
	for (NSUInteger n = 0; n < [palette colorCount]; n++) {
		PXPaletteColorLayer *colorLayer = [PXPaletteColorLayer layer];
		colorLayer.index = n;
		colorLayer.color = [palette colorAtIndex:n];
		colorLayer.controlSize = controlSize;
		
		[self.layer addSublayer:colorLayer];
		[colorLayer setNeedsDisplay];
	}
	
	[self.layer setNeedsLayout];
	
	/*
	 if(!enabled)
	 {
	 [[NSColor colorWithDeviceWhite:1 alpha:.2] set];
	 NSRectFillUsingOperation([self visibleRect], NSCompositeSourceOver);
	 }
	 */
}

- (void)setNeedsRetile
{
	[[self class] cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(retile) withObject:nil afterDelay:0.0f];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
	return YES;
}

- (void)paletteChanged:(NSNotification *)notification
{
	[self setNeedsRetile];
}

- (void)setPalette:(PXPalette *)pal
{
	[palette release];
	palette = [pal retain];
	
	[self setNeedsRetile];
}

- (void)rightMouseDown:(NSEvent *)event
{
	[self mouseDown:event];
}

- (void)rightMouseDragged:(NSEvent *)event
{
	[self mouseDragged:event];
}

- (void)rightMouseUp:(NSEvent *)event
{
	[self mouseUp:event];
}

- (NSUInteger)indexOfCelAtPoint:(NSPoint)point
{
	int firstRow = MAX(floorf(NSMinY([self visibleRect]) / height), 0);
	int lastRow = MIN(ceilf(NSMaxY([self visibleRect]) / height), rows-1);
	
	int i, j;
	for (j = firstRow; j <= lastRow; j++)
	{
		for (i = 0; i < columns; i++)
		{
			NSUInteger index = j * columns + i;
			
			if (index >= ([palette colorCount]))
				break;
			
			NSRect frame = NSMakeRect(viewMargin*2 + i*width, viewMargin*2 + j*height, width - viewMargin*2, height - viewMargin*2);
			
			if (NSPointInRect(point, frame))
				return index;
		}
	}
	
	return NSNotFound;
}

- (void)setControlSize:(NSControlSize)aSize
{
	controlSize = aSize;
	[self setNeedsRetile];
}

- (void)sizeSelector:selector selectedSize:(NSControlSize)aSize
{
	[self setControlSize:aSize];
	
	if ([delegate respondsToSelector:@selector(paletteViewSizeChangedTo:)])
	{
		[delegate paletteViewSizeChangedTo:aSize];
	}
}

- (void)deleteBackward:(id)sender
{
	if (!palette)
		return;
	
	if (selectionIndex == NSNotFound || !palette.canSave) {
		NSBeep();
		return;
	}
	
	[palette removeColorAtIndex:selectionIndex];
	[palette save];
	
	[self retile];
}

- (void)moveLeft:(id)sender
{
	if (selectionIndex > 0) {
		NSUInteger index = selectionIndex;
		
		[self toggleHighlightOnLayerAtIndex:selectionIndex];
		index--;
		[self toggleHighlightOnLayerAtIndex:index];
		
		if ([delegate respondsToSelector:@selector(useColorAtIndex:)])
			[delegate useColorAtIndex:index];
	}
	else {
		NSBeep();
	}
}

- (void)moveRight:(id)sender
{
	if (selectionIndex < ([palette colorCount]-1)) {
		NSUInteger index = selectionIndex;
		
		[self toggleHighlightOnLayerAtIndex:selectionIndex];
		index++;
		[self toggleHighlightOnLayerAtIndex:index];
		
		if ([delegate respondsToSelector:@selector(useColorAtIndex:)])
			[delegate useColorAtIndex:index];
	}
	else {
		NSBeep();
	}
}

- (void)toggleHighlightOnLayerAtIndex:(NSUInteger)index
{
	if (!highlightEnabled)
		return;
	
	for (CALayer *layer in [[self layer] sublayers])
	{
		if (![layer isKindOfClass:[PXPaletteColorLayer class]])
			continue;
		
		PXPaletteColorLayer *colorLayer = (PXPaletteColorLayer *) layer;
		
		if (index == colorLayer.index) {
			if (colorLayer.highlighted) {
				colorLayer.highlighted = NO;
				selectionIndex = NSNotFound;
			}
			else {
				colorLayer.highlighted = YES;
				selectionIndex = index;
			}
			
			break;
		}
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
	if (!highlightEnabled)
		return; // disable moveRight:, moveLeft:, and deleteBackward:
	
	[self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}

- (void)activateIndexWithEvent:(NSEvent *)event
{
	if (selectionIndex != NSNotFound) {
		[self toggleHighlightOnLayerAtIndex:selectionIndex];
	}
	
	if (!palette || !enabled)
		return;
	
	NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
	NSUInteger index = [self indexOfCelAtPoint:point];
	
	if (index == NSNotFound)
		return;
	
	[self toggleHighlightOnLayerAtIndex:index];
	
	if ([delegate respondsToSelector:@selector(useColorAtIndex:)])
		[delegate useColorAtIndex:index];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
	if (!palette || !palette.canSave)
		return NSDragOperationNone;
	
	NSPoint point = [self convertPoint:[sender draggingLocation] fromView:nil];
	NSUInteger index = [self indexOfCelAtPoint:point];
	
	if (index == NSNotFound)
		return NSDragOperationNone;
	
	return NSDragOperationGeneric;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
	return [self draggingEntered:sender];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
	return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
	NSArray *colors = [[sender draggingPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[NSColor class]]
																 options:nil];
	
	if (![colors count])
		return NO;
	
	NSColor *color = [colors objectAtIndex:0];
	
	NSPoint point = [self convertPoint:[sender draggingLocation] fromView:nil];
	NSUInteger index = [self indexOfCelAtPoint:point];
	
	[palette replaceColorAtIndex:index withColor:color];
	[palette save];
	
	return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
	[self retile];
}

- (void)mouseDown:(NSEvent *)event
{
	if ([event clickCount] == 2 && highlightEnabled) {
		NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
		NSUInteger index = [self indexOfCelAtPoint:point];
		
		if (index == NSNotFound)
			return;
		
		if ([delegate respondsToSelector:@selector(paletteView:modifyColorAtIndex:)])
			[delegate paletteView:self modifyColorAtIndex:index];
		
		return;
	}
	
	[self activateIndexWithEvent:event];
}

- (void)mouseDragged:(NSEvent *)event
{
	[self activateIndexWithEvent:event];
	[self autoscroll:event];
}

- (void)mouseUp:(NSEvent *)event
{
	// [self activateIndexWithEvent:event];
}

@end
