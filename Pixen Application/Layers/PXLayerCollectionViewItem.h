//
//  PXLayerCollectionViewItem.h
//  Pixen
//
//  Created by Joseph C Osborn on 2011.06.15.
//  Copyright 2011 Universal Happy-Maker. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PXLayerDetailsView, PXNSImageView, PXLayerTextField, PXLayerController, PXLayer;

@interface PXLayerCollectionViewItem : NSCollectionViewItem {
  @private
	IBOutlet PXLayerDetailsView *backgroundView;
	IBOutlet PXLayerTextField *nameField;
	IBOutlet PXNSImageView *thumbnailView;
	IBOutlet NSTextField *opacityField;
	
	PXLayer *layer;
	PXLayerController *layerController;
}

@property (nonatomic, assign) PXLayerController *layerController;

- (void)focusOnName;
- (void)unload;

@end
