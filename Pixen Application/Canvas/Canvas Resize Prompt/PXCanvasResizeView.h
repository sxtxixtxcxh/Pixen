//
//  PXCanvasResizeView.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@interface PXCanvasResizeView : NSView

@property (nonatomic, retain) NSColor *backgroundColor;

@property (nonatomic, retain) NSImage *cachedImage;
@property (nonatomic, assign) NSSize newImageSize;
@property (nonatomic, assign) NSSize oldImageSize;

@property (nonatomic, assign) CGFloat leftOffset;
@property (nonatomic, assign) CGFloat topOffset;

- (NSPoint)resultPosition;

@end
