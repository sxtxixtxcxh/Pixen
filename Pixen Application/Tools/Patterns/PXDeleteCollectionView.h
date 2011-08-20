//
//  PXDeleteCollectionView.h
//  Pixen
//
//  Created by Matt Rajca on 8/19/11.
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXDeleteCollectionView : NSCollectionView

@end


@interface NSObject(PXDeleteCollectionViewDelegate)

- (void)deleteKeyPressedInCollectionView:(NSCollectionView *)view;

@end
