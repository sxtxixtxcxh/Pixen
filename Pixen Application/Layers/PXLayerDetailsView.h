//
//  PXLayerDetailsView.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

@interface PXLayerDetailsView : NSView
{
  @private
	BOOL _selected;
}

@property (nonatomic, assign, getter=isSelected) BOOL selected;

@end
