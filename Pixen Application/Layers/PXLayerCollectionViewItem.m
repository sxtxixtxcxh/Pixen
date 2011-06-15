//
//  PXLayerCollectionViewItem.m
//  Pixen
//
//  Created by Joseph C Osborn on 2011.06.15.
//  Copyright 2011 Universal Happy-Maker. All rights reserved.
//

#import "PXLayerCollectionViewItem.h"
#import "PXLayerDetailsView.h"

@implementation PXLayerCollectionViewItem

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setSelected:(BOOL)flag
{
	[super setSelected:flag];
	[(PXLayerDetailsView *)[self view] setSelected:flag];
	[[self view] setNeedsDisplay:YES];
}

@end
