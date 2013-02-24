//
//  PXClickableView.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

@interface PXClickableView : NSView
{
  @private
	BOOL _selected;
}

@property (nonatomic, assign) BOOL selected;

@end
