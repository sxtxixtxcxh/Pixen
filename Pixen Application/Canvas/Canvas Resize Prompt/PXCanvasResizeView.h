//
//  PXCanvasResizeView.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@interface PXCanvasResizeView : NSView
{
	NSPoint _position;
	NSAffineTransform *_scaleTransform;

    NSColor *_backgroundColor;
    NSImage *_cachedImage;
    NSSize _newSize;
    NSSize _oldSize;
    CGFloat _leftOffset;
    CGFloat _topOffset;
}

@property (nonatomic, retain) NSColor *backgroundColor;

@property (nonatomic, retain) NSImage *cachedImage;
@property (nonatomic, assign) NSSize newImageSize;
@property (nonatomic, assign) NSSize oldImageSize;

@property (nonatomic, assign) CGFloat leftOffset;
@property (nonatomic, assign) CGFloat topOffset;

- (NSPoint)resultPosition;

@end
