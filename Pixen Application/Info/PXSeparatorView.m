//
//  PXSeparatorView.m
//  Pixen
//
//  Copyright 2013 Pixen Project. All rights reserved.
//

#import "PXSeparatorView.h"

@implementation PXSeparatorView {
	NSGradient *_cachedGradient;
}

- (void)drawRect:(NSRect)dirtyRect {
	if (!_cachedGradient) {
		_cachedGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.50f alpha:1.0f]
														endingColor:[NSColor colorWithCalibratedWhite:0.65f alpha:1.0f]];
	}
	
	[_cachedGradient drawInRect:[self bounds] angle:90.0f];
}

@end
