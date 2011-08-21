//
//  PXPatternItem.m
//  Pixen
//
//  Created by Matt Rajca on 8/20/11.
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import "PXPatternItem.h"

#import "PXClickableView.h"

@implementation PXPatternItem

- (void)viewDidReceiveDoubleClick:(NSView *)view
{
	if ([[[self collectionView] delegate] respondsToSelector:@selector(patternItemWasDoubleClicked:)])
		[ (id) [[self collectionView] delegate] patternItemWasDoubleClicked:self];
}

- (void)setSelected:(BOOL)flag {
	[super setSelected:flag];
	
	[ (PXClickableView *) [self view] setSelected:flag];
}

@end
