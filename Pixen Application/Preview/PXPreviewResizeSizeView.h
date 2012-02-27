//
//  PXPreviewResizeSizeView.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXPreviewResizeSizeView : NSView
{
  @private
	NSAttributedString *_scaleString;
}

- (BOOL)updateScale:(CGFloat)scale;
- (NSSize)scaleStringSize;

@end
