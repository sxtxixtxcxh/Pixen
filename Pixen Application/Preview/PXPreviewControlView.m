//
//  PXPreviewControlView.m
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "PXPreviewControlView.h"

@implementation PXPreviewControlView

- (void)drawRect:(NSRect)dirtyRect
{
    [[[NSColor blackColor] colorWithAlphaComponent:0.7f] set];
	[[NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:10.0f yRadius:10.0f] fill];
}

@end
