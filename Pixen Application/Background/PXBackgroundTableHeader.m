//
//  PXBackgroundTableHeader.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXBackgroundTableHeader.h"

@implementation PXBackgroundTableHeader

- (id)initWithFrame:(NSRect)frameRect {
	if ((self = [super initWithFrame:frameRect])) {
		[self setButtonType:NSMomentaryChangeButton];
		self.bezelStyle = NSThickSquareBezelStyle;
	}
	return self;
}

- (void)mouseDown:(NSEvent *)event
{
	// don't make the button highlight
}

- (void)_windowChangedKeyState
{
	// don't make the color change
}

@end
