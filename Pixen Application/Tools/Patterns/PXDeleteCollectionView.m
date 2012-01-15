//
//  PXDeleteCollectionView.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXDeleteCollectionView.h"

@implementation PXDeleteCollectionView

- (void)keyDown:(NSEvent*)theEvent { 
	if ([[theEvent characters] isEqualToString: @"\177"]) {
		[ (id) [self delegate] deleteKeyPressedInCollectionView:self];
		return;
	}
	
	[super keyDown:theEvent];
}

@end
