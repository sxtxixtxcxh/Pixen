//
//  PXLayerCellView.m
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "PXLayerCellView.h"

@implementation PXLayerCellView

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
	[super setBackgroundStyle:backgroundStyle];
	
	if (backgroundStyle == NSBackgroundStyleDark) {
		[self.opacityField setTextColor:[NSColor whiteColor]];
		[[self.opacityField cell] setBackgroundStyle:NSBackgroundStyleLowered];
	}
	else if (backgroundStyle == NSBackgroundStyleLight) {
		[self.opacityField setTextColor:[NSColor disabledControlTextColor]];
		[[self.opacityField cell] setBackgroundStyle:NSBackgroundStyleLight];
	}
}

@end
