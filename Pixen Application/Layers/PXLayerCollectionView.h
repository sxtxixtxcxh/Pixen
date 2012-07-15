//
//  PXLayerCollectionView.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXDeleteCollectionView.h"

@class PXLayerController;

@interface PXLayerCollectionView : PXDeleteCollectionView

@property (nonatomic, weak) PXLayerController *layerController;

@end
