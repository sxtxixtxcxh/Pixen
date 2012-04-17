//
//  PXLayerCollectionView.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXLayerCollectionView.h"

#import "PXLayerCollectionViewItem.h"
#import "PXLayerController.h"
#import "PXLayerDetailsView.h"

@implementation PXLayerCollectionView

@synthesize layerController = _layerController;

- (BOOL)acceptsFirstResponder
{
	return NO;
}

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object
{
	PXLayerCollectionViewItem *item = [[PXLayerCollectionViewItem alloc] init];
	[item loadView];
	
	item.representedObject = object;
	item.layerController = self.layerController;
	
	return item;
}

@end
