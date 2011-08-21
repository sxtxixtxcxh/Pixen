//
//  PXPatternItem.h
//  Pixen
//
//  Created by Matt Rajca on 8/20/11.
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface PXPatternItem : NSCollectionViewItem

@end


@interface NSObject (PXPatternItemDelegate)

- (void)patternItemWasDoubleClicked:(PXPatternItem *)item;

@end
