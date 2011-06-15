//
//  PXLayerTableView.h
//  Pixen
//
//  Created by Andy Matuschak on 6/19/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PXLayerDetailsView, PXLayerTableView;

@protocol PXLayerTableViewDelegate
- (void)deleteKeyPressedInTableView:(PXLayerTableView *)tableView;
- (PXLayerDetailsView *)tableView:(PXLayerTableView *)tv viewForRow:(int)row;
@end

@interface PXLayerTableView : NSTableView {

}

@end
