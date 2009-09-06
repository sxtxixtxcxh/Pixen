//
//  PXPalettePanelPaletteView.m
//  Pixen
//
//  Created by Andy Matuschak on 8/20/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXPalettePanelPaletteView.h"
#import "PXColorPickerColorWellCell.h"

@implementation PXPalettePanelPaletteView

- initWithFrame:(NSRect)frame
{
	[super initWithFrame:frame];
	rightIndex = -1;
	return self;
}

- (void)setRightIndex:(int)index
{
	rightIndex = index;
	[self setNeedsDisplayInRect:[self visibleRect]];
}

- (PXColorCelState)stateForCelIndex:(int)index
{
	if (index == -1) { return PXNoToolColor; }
	if ((selectedIndex == index) && (rightIndex == index)) { return PXBothToolColor; }
	else if (selectedIndex == index) { return PXLeftToolColor; }
	else if (rightIndex == index) { return PXRightToolColor; }
	else { return PXNoToolColor; }
}

- (void)mouseDown:(NSEvent *)event
{
	if ([event modifierFlags] & NSControlKeyMask)
	{
		[self rightMouseDown:event];
	}
	else
	{
		[super mouseDown:event];
	}
}

- (void)mouseUp:(NSEvent *)event
{
	if ([event modifierFlags] & NSControlKeyMask)
	{
		[self rightMouseUp:event];
	}
	else
	{
		[super mouseUp:event];
	}
}

- (void)rightMouseDown:(NSEvent *)event
{
	if(!enabled) { return; }
	int paletteIndex = [self indexOfCelAtPoint:[self convertPoint:[event locationInWindow] fromView:nil]];
	if (paletteIndex == -1) { return; }

	[delegate useColorAtIndex:paletteIndex event:event];
	rightIndex = paletteIndex;
	[self setNeedsDisplayInRect:[self visibleRect]];
}

// Intentionally no-op:
- (void)rightMouseDragged:(NSEvent *)event {}
- (void)rightMouseUp:(NSEvent *)event {}

@end
