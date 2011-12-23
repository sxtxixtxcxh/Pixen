//
//  PXLayerDetailsView.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

@interface PXLayerDetailsView : NSView
{
	BOOL _selected;
}

@property (nonatomic, assign, getter=isSelected) BOOL selected;

@end
