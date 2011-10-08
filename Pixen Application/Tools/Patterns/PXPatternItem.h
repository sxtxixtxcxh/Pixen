//
//  PXPatternItem.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

@interface PXPatternItem : NSCollectionViewItem

@end


@interface NSObject (PXPatternItemDelegate)

- (void)patternItemWasDoubleClicked:(PXPatternItem *)item;

@end
