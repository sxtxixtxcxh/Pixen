//
//  PXPreviewBezelView.h
//  Pixen-XCode
//
//  Created by Andy Matuschak on 5/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <AppKit/NSView.h>

@interface PXPreviewBezelView : NSView < NSAnimatablePropertyContainer > {
  @private
	NSImage * actionGear;
	NSMenu * menu;
	id delegate;
	CGFloat alpha;
}

- (void)setDelegate:delegate;

@property (nonatomic, assign) CGFloat opacity;

@end
