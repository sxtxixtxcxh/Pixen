//
//  PXPatternItem.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXPatternItem.h"

#import "PXClickableView.h"

@implementation PXPatternItem

- (void)setSelected:(BOOL)flag {
	[super setSelected:flag];
	
	[ (PXClickableView *) [self view] setSelected:flag];
}

@end
