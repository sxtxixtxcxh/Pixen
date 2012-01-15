//
//  PXPatternItem.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

@interface PXPatternItem : NSCollectionViewItem

@end


@interface NSObject (PXPatternItemDelegate)

- (void)patternItemWasDoubleClicked:(PXPatternItem *)item;

@end
