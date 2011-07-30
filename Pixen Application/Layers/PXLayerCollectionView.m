//
//  PXLayerCollectionView.m
//  Pixen
//
//  Created by Andy Matuschak on 6/19/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXLayerCollectionView.h"
#import "PXLayerController.h"
#import "PXLayerDetailsView.h"
#import "PXLayerCollectionViewItem.h"

@implementation PXLayerCollectionView

- (void)keyDown:(NSEvent*)theEvent { 
	if ([[theEvent characters] isEqualToString: @"\177"]) {
		[(PXLayerController *)[self delegate] deleteKeyPressedInCollectionView:self];
	}
	[super keyDown:theEvent];
}

- (BOOL)acceptsFirstResponder
{
	return NO;
}

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object {
	PXLayerCollectionViewItem *item = [[PXLayerCollectionViewItem alloc] init];
	item.representedObject = object;
	item.view = object;
	return item;
}

@end
