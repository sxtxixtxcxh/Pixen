//
//  PXLayerPaneBackgroundView.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXLayerPaneBackgroundView.h"

@implementation PXLayerPaneBackgroundView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	CGFloat positions[4] = { 0.0f, 11.5f / 23, 11.5f / 23, 1.0f };
	
	NSColor *color1 = [NSColor colorWithCalibratedRed:0.90f green:0.90f blue:0.90f alpha:1.0f];
	NSColor *color2 = [NSColor colorWithCalibratedRed:0.92f green:0.92f blue:0.92f alpha:1.0f];
	NSColor *color3 = [NSColor colorWithCalibratedRed:0.84f green:0.84f blue:0.84f alpha:1.0f];
	NSColor *color4 = [NSColor colorWithCalibratedRed:0.95f green:0.95f blue:0.95f alpha:1.0f];
	
	_gradient = [[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:color1, color2, color3, color4, nil]
									   atLocations:positions
										colorSpace:[NSColorSpace genericRGBColorSpace]];
	
	return self;
}

- (void)drawRect:(NSRect)rect
{
	NSRect targetRect = NSMakeRect(0.0f, 0.0f, NSWidth([self bounds]), 25.0f);
	[_gradient drawInRect:targetRect angle:270.0f];
}

@end
