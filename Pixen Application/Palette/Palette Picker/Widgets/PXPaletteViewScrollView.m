//
//  PXPaletteViewScrollView.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXPaletteViewScrollView.h"

#import "PXPaletteViewSizeSelector.h"

@implementation PXPaletteViewScrollView

@dynamic controlSize;

- (void)awakeFromNib
{
	_sizeSelector = [[PXPaletteViewSizeSelector alloc] initWithFrame:NSMakeRect(0, 0, 15, 29)];
	[_sizeSelector setDelegate:[self documentView]];
	
	[self addSubview:_sizeSelector];
}

- (void)tile
{
	[super tile];
	NSRect scrollerRect, sizeSelectorRect;
	scrollerRect = [[self verticalScroller] frame];
	NSDivideRect(scrollerRect, &sizeSelectorRect, &scrollerRect, 29, NSMinYEdge);
	[[self verticalScroller] setFrame:scrollerRect];
	
	[_sizeSelector setFrame:sizeSelectorRect];
	[_sizeSelector setNeedsDisplay:YES];
}

- (NSControlSize)controlSize
{
	return [_sizeSelector controlSize];
}

- (void)setControlSize:(NSControlSize)size
{
	[_sizeSelector setControlSize:size];
	[[self documentView] setControlSize:size];
}

@end
