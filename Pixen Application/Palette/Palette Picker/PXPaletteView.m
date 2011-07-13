//
//  PXPaletteView.m
//  Pixen
//
//  Copyright 2011 Open Sword Group. All rights reserved.
//

#import "PXPaletteView.h"

#import "PXDocument.h"
#import "PXPaletteColorLayer.h"

@implementation PXPaletteView

const CGFloat viewMargin = 1.0f;

@synthesize enabled, controlSize, document, palette, delegate;

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self setEnabled:YES];
		
		palette = NULL;
		controlSize = NSRegularControlSize;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(paletteChanged:)
													 name:PXPaletteChangedNotificationName
												   object:nil];
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
	rows = palette ? ceilf((float)((PXPalette_colorCount(palette))) / columns) : 0;
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
		
		int n = [ (PXPaletteColorLayer *) layer index];
		
		int i = n % columns;
		int j = n / columns;
		
		layer.frame = CGRectMake(viewMargin*2 + i*width, viewMargin*2 + j*height, width - viewMargin*2, height - viewMargin*2);
	}
}

- (void)retile
{
	[self size];
	[self setFrameSize:NSMakeSize(NSWidth([[self superview] bounds]), MAX(rows * height + viewMargin*2, NSHeight([[self superview] bounds])))];
	
	self.layer.sublayers = nil;
	
	if (!palette)
		return;
	
	int count = PXPalette_colorCount(palette);
	PXPaletteColorPair *colors = palette->colors;
	
	for (int n = 0; n < count; n++) {
		PXPaletteColorLayer *colorLayer = [PXPaletteColorLayer layer];
		colorLayer.index = n;
		colorLayer.color = colors[n].color;
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

- (void)setNeedsRetile {
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
	if (!pal)
	{
		if (palette)
		{
			PXPalette_release(palette);
			palette = nil;
		}
		return;
	}
	
	PXPalette_retain(pal);
	PXPalette_release(palette);
	palette = pal;
	
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

- (int)indexOfCelAtPoint:(NSPoint)point
{
	int firstRow = MAX(floorf(NSMinY([self visibleRect]) / height), 0);
	int lastRow = MIN(ceilf(NSMaxY([self visibleRect]) / height), rows-1);
	
	int i, j;
	for (j = firstRow; j <= lastRow; j++)
	{
		for (i = 0; i < columns; i++)
		{
			int index = j * columns + i;
			
			if (index >= (PXPalette_colorCount(palette)))
				break;
			
			NSRect frame = NSMakeRect(viewMargin*2 + i*width, viewMargin*2 + j*height, width - viewMargin*2, height - viewMargin*2);
			
			if (NSPointInRect(point, frame))
				return index;
		}
	}
	
	return -1;
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

- (void)activateIndexWithEvent:(NSEvent *)event
{
	NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
	
	if (!palette || !enabled)
		return;
	
	int index = [self indexOfCelAtPoint:p];
	
	if (index == -1)
		return;
	
	int paletteIndex = index;
	
	if (paletteIndex == -1)
		return;
	
	if ([delegate respondsToSelector:@selector(useColorAtIndex:event:)])
		[delegate useColorAtIndex:paletteIndex event:event];
}

- (void)mouseDown:(NSEvent *)event
{
	[self activateIndexWithEvent:event];
}

- (void)mouseDragged:(NSEvent *)event
{
	[self activateIndexWithEvent:event];
	[self autoscroll:event];
}

- (void)mouseUp:(NSEvent *)event
{
	[self activateIndexWithEvent:event];
}

@end
