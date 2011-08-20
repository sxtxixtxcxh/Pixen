//
//  PXDeleteCollectionView.m
//  Pixen
//
//  Created by Matt Rajca on 8/19/11.
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import "PXDeleteCollectionView.h"

@implementation PXDeleteCollectionView

- (void)keyDown:(NSEvent*)theEvent { 
	if ([[theEvent characters] isEqualToString: @"\177"]) {
		[[self delegate] deleteKeyPressedInCollectionView:self];
		return;
	}
	
	[super keyDown:theEvent];
}

@end
