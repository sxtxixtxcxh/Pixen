//
//  PXLayerCollectionView.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXDeleteCollectionView.h"

@class PXLayerController;

@interface PXLayerCollectionView : PXDeleteCollectionView

@property (nonatomic, assign) PXLayerController *layerController;

@end
