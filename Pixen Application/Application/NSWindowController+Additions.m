//
//  NSWindowController+Additions.m
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "NSWindowController+Additions.h"

@implementation NSWindowController (Additions)

- (BOOL)isVisible
{
	return [self isWindowLoaded] && [self.window isVisible];
}

- (void)toggleWindow
{
	if ([self isVisible]) {
		[self close];
	}
	else {
		[self showWindow:nil];
	}
}

@end
