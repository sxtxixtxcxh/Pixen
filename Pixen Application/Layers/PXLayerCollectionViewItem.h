//
//  PXLayerCollectionViewItem.h
//  Pixen
//
//  Created by Joseph C Osborn on 2011.06.15.
//  Copyright 2011-2012 Universal Happy-Maker. All rights reserved.
//

@class PXLayerDetailsView, PXNSImageView, PXLayerTextField, PXLayerController, PXLayer;

@interface PXLayerCollectionViewItem : NSCollectionViewItem
{
  @private
	PXLayerDetailsView *_backgroundView;
	IBOutlet PXLayerTextField *nameField;
	IBOutlet PXNSImageView *thumbnailView;
	IBOutlet NSTextField *opacityField;
	
	PXLayerController *layerController;
}

@property (nonatomic, assign) PXLayerController *layerController;

@property (nonatomic, assign) IBOutlet PXLayerDetailsView *backgroundView;

- (void)focusOnName;
- (void)unload;

@end
