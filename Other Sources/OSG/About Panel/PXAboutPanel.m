//
//  PXAboutPanel.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXAboutPanel.h"

@implementation PXAboutPanel

- (BOOL)canBecomeMainWindow
{
	return YES;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (void)sendEvent:(NSEvent *)theEvent
{
	if ([theEvent type] == NSKeyDown) {
		if ([[self delegate] respondsToSelector:@selector(handlesKeyDown:inWindow:)]) {
			if ([ (id < PXAboutPanelDelegate >) [self delegate] handlesKeyDown:theEvent inWindow:self])
				return;
		}
	}
	
	[super sendEvent: theEvent];
}

@end
