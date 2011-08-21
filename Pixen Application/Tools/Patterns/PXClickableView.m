//
//  PXClickableView.m
//  Pixen
//
//  Created by Matt Rajca on 8/20/11.
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import "PXClickableView.h"

@implementation PXClickableView

- (void)mouseDown:(NSEvent *)theEvent
{
	if ([theEvent clickCount] > 1) {
		if ([delegate respondsToSelector:@selector(viewDidReceiveDoubleClick:)])
			[delegate viewDidReceiveDoubleClick:self];
	}
}

@end
