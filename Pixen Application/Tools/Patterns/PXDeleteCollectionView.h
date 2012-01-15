//
//  PXDeleteCollectionView.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

@interface PXDeleteCollectionView : NSCollectionView

@end


@interface NSObject(PXDeleteCollectionViewDelegate)

- (void)deleteKeyPressedInCollectionView:(NSCollectionView *)view;

@end
