//
//  PXBackgroundsPanel.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXBackgroundsPanel.h"

@implementation PXBackgroundsPanel

- (void)becomeKeyWindow
{
	[super becomeKeyWindow];
	[[self contentView] display];
}

- (void)close
{
#warning TODO: this is buggy
	// The windowWillClose method seems to be getting intercepted somewhere, so we send it manually.
	[[self delegate] windowWillClose:nil];
	[super close];
}

- (void)resignKeyWindow
{
	[super resignKeyWindow];
	[[self contentView] display];
}

@end
