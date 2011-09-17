//
//  PXLayerCollectionView.h
//  Pixen
//
//  Created by Andy Matuschak on 6/19/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXDeleteCollectionView.h"

@class PXLayerController;

@interface PXLayerCollectionView : PXDeleteCollectionView {
  @private
	PXLayerController *layerController;
}

@property (nonatomic, assign) PXLayerController *layerController;

@end
