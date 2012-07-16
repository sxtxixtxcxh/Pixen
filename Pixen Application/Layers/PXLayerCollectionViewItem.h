//
//  PXLayerCollectionViewItem.h
//  Pixen
//
//  Created by Joseph C Osborn on 2011.06.15.
//  Copyright 2011-2012 Universal Happy-Maker. All rights reserved.
//

@class PXLayerDetailsView, PXNSImageView, PXLayerTextField, PXLayerController, PXLayer;

@interface PXLayerCollectionViewItem : NSCollectionViewItem

@property (nonatomic, weak) IBOutlet PXLayerTextField *nameField;
@property (nonatomic, weak) IBOutlet PXNSImageView *thumbnailView;
@property (nonatomic, weak) IBOutlet NSTextField *opacityField;

@property (nonatomic, weak) PXLayerController *layerController;

@property (nonatomic, weak) IBOutlet PXLayerDetailsView *backgroundView;

- (void)focusOnName;
- (void)unload;

@end
