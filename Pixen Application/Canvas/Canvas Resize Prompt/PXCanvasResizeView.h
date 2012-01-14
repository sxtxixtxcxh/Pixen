//
//  PXCanvasResizeView.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXCanvasResizeView : NSView
{
  @private
	NSPoint _position;
	NSAffineTransform *_scaleTransform;
	
	NSColor *_backgroundColor;
	NSImage *_cachedImage;
	NSSize _newSize, _oldSize;
	CGFloat _leftOffset, _topOffset;
}

@property (nonatomic, retain) NSColor *backgroundColor;

@property (nonatomic, retain) NSImage *cachedImage;
@property (nonatomic, assign) NSSize newImageSize;
@property (nonatomic, assign) NSSize oldImageSize;

@property (nonatomic, assign) CGFloat leftOffset;
@property (nonatomic, assign) CGFloat topOffset;
@property (nonatomic, assign) CGFloat bottomOffset;
@property (nonatomic, assign) CGFloat rightOffset;

- (NSPoint)resultantPosition;

@end
