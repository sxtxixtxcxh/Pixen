//
//  PXClickableView.h
//  Pixen
//
//  Created by Matt Rajca on 8/20/11.
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXClickableView : NSView {
  @private
	BOOL _selected;
	IBOutlet id delegate;
}

- (void)setSelected:(BOOL)selected;

@end


@interface NSObject (PXClickableViewDelegate)

- (void)viewDidReceiveDoubleClick:(NSView *)view;

@end
