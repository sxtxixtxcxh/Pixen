//
//  PXActionButton.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXActionButton : NSPopUpButton
{
  @private
	NSImage *_image;
}

@property (nonatomic, retain) NSImage *image;

@end
