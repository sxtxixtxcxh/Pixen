//
//  PXPreviewResizeSizeView.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@interface PXPreviewResizeSizeView : NSView
{
	NSAttributedString *_scaleString;
}

- (BOOL)updateScale:(CGFloat)scale;
- (NSSize)scaleStringSize;

@end
