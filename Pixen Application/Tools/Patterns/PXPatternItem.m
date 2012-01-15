//
//  PXPatternItem.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
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
