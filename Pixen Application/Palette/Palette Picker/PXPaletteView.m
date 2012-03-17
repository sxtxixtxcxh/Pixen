//
//  PXPaletteView.m
//  Pixen
//
//  Copyright 2011-2012 Pixen. All rights reserved.
//

#import "PXPaletteView.h"

#import <QuartzCore/QuartzCore.h>

#import "PXPaletteColorLayer.h"

@implementation PXPaletteView

const CGFloat viewMargin = 1.0f;

@synthesize highlightEnabled, controlSize, palette, delegate;

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if (self) {
		_visibleLayers = [NSMutableSet new];
		_recycledLayers = [NSMutableSet new];
		
		selectionIndex = NSNotFound;
		controlSize = NSRegularControlSize;
		highlightEnabled = YES;
		
		[self registerForDraggedTypes:[NSArray arrayWithObject:NSPasteboardTypeColor]];
	}
	return self;
}

- (void)viewDidMoveToSuperview
{
	NSView *superview = [self superview];
	
	if ([superview isKindOfClass:[NSClipView class]]) {
		[superview setPostsBoundsChangedNotifications:YES];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(scrollViewDidScroll:)
													 name:NSViewBoundsDidChangeNotification
												   object:superview];
		
		[self reload];
	}
}

- (void)scrollViewDidScroll:(NSNotification *)notification
{
	[self retile];
}

- (void)awakeFromNib
{
	[self setupLayer];
}

- (void)setupLayer
{
	CALayer *rootLayer = [self layer];
	rootLayer.geometryFlipped = YES;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[palette release];
	[_visibleLayers release];
	[_recycledLayers release];
	
	[super dealloc];
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)reload
{
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	for (PXPaletteColorLayer *layer in _visibleLayers)
	{
		[_recycledLayers addObject:layer];
		[layer removeFromSuperlayer];
	}
	
	[_visibleLayers minusSet:_recycledLayers];
	
	[self size];
	[self retile];
	
	[CATransaction commit];
}

- (void)size
{
	width = (controlSize == NSRegularControlSize ? 32 : 16) + viewMargin;
	columns = NSWidth([self bounds]) / width;
	rows = palette ? ceilf((float)(([palette colorCount])) / columns) : 0;
	
	[self setFrameSize:NSMakeSize(NSWidth([[self superview] bounds]), MAX(rows * width + viewMargin*2, NSHeight([[self superview] bounds])))];
}

- (void)viewDidEndLiveResize
{
	[self reload];
}

- (PXPaletteColorLayer *)dequeueRecycledLayer
{
	PXPaletteColorLayer *layer = [_recycledLayers anyObject];
	
	if (layer) {
		[[layer retain] autorelease];
		[_recycledLayers removeObject:layer];
	}
	
	return layer;
}

- (BOOL)isDisplayingLayerForIndex:(NSUInteger)index
{
	for (PXPaletteColorLayer *layer in _visibleLayers) {
		if (layer.index == index)
			return YES;
	}
	
	return NO;
}

- (void)retile
{
	if (!palette)
		return;
	
	NSRect visibleBounds = [[self superview] bounds];
	
	NSInteger firstIndex = floorf(NSMinY(visibleBounds) / width) * columns;
	NSInteger lastIndex = ceilf(NSMaxY(visibleBounds) / width) * columns + columns;
	
	firstIndex = MAX(firstIndex, 0);
	lastIndex = MIN(lastIndex, MAX([palette colorCount], 1) - 1);
	
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	// Recycle no-longer-visible layers
	for (PXPaletteColorLayer *layer in _visibleLayers)
	{
		if (layer.index < firstIndex || layer.index > lastIndex) {
			[_recycledLayers addObject:layer];
			[layer removeFromSuperlayer];
		}
	}
	
	[_visibleLayers minusSet:_recycledLayers];
	
	if (![palette colorCount]) {
		[CATransaction commit];
		return;
	}
	
	// add missing layers
	for (NSUInteger n = firstIndex; n <= lastIndex; n++)
	{
		if ([self isDisplayingLayerForIndex:n])
			continue;
		
		PXPaletteColorLayer *layer = [self dequeueRecycledLayer];
		
		if (!layer) {
			layer = [PXPaletteColorLayer layer];
		}
		
		NSUInteger i = n % columns;
		NSUInteger j = n / columns;
		
		layer.frame = CGRectMake(viewMargin*2 + i*width, viewMargin*2 + j*width, width - viewMargin*2, width - viewMargin*2);
		
		layer.index = n;
		layer.color = PXColorToNSColor([palette colorAtIndex:n]);
		layer.controlSize = controlSize;
		
		[self.layer addSublayer:layer];
		
		[_visibleLayers addObject:layer];
	}
	
	[CATransaction commit];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
	return YES;
}

- (void)setPalette:(PXPalette *)pal
{
	if (palette != pal)
	{
		selectionIndex = NSNotFound;
		
		[palette release];
		palette = [pal retain];
		
		[self reload];
	}
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
	int firstRow = MAX(floorf(NSMinY([self visibleRect]) / width), 0);
	int lastRow = MIN(ceilf(NSMaxY([self visibleRect]) / width), rows-1);
	
	int i, j;
	for (j = firstRow; j <= lastRow; j++)
	{
		for (i = 0; i < columns; i++)
		{
			NSUInteger index = j * columns + i;
			
			if (index >= [palette colorCount])
				break;
			
			NSRect frame = NSMakeRect(viewMargin*2 + i*width, viewMargin*2 + j*width, width - viewMargin*2, width - viewMargin*2);
			
			if (NSPointInRect(point, frame))
				return index;
		}
	}
	
	return NSNotFound;
}

- (void)setControlSize:(NSControlSize)aSize
{
	if (controlSize != aSize) {
		controlSize = aSize;
		
		[self reload];
	}
}

- (void)sizeSelector:selector selectedSize:(NSControlSize)aSize
{
	[self setControlSize:aSize];
	
	if ([delegate respondsToSelector:@selector(paletteViewSizeChangedTo:)]) {
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
	
	[self reload];
}

- (void)moveLeft:(id)sender
{
	if (selectionIndex > 0 && selectionIndex != NSNotFound) {
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
	if (selectionIndex < ([palette colorCount]-1) && selectionIndex != NSNotFound) {
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
	
	if (!palette)
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
	
	[palette replaceColorAtIndex:index withColor:PXColorFromNSColor(color)];
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
