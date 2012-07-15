//
//  PXPreviewBezelView.h
//  Pixen-XCode
//
//  Created by Andy Matuschak on 5/7/05.
//  Copyright 2005 Pixen. All rights reserved.
//

@interface PXPreviewBezelView : NSView < NSAnimatablePropertyContainer >
{
  @private
	NSMenu * menu;
	CGFloat alpha;
}

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) CGFloat opacity;

@end
