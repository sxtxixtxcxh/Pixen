//
//  PXCanvasResizeView.h
//  Pixen
//

#import <AppKit/AppKit.h>


@interface PXCanvasResizeView : NSView 
{
  @private
	NSSize oldSize;
	NSSize newSize;
	NSPoint position;
	NSImage *cachedImage;
	NSColor *backgroundColor;
	
	NSAffineTransform *scaleTransform;
}

- (NSSize)newSize;
- (NSPoint)resultPosition;

- backgroundColor;
- (void)setBackgroundColor:(NSColor *)color;
- (void)setCachedImage:(NSImage *)cachedImage;
- (void)setNewImageSize:(NSSize)newSize;
- (void)setOldImageSize:(NSSize)oldSize;

- (int)leftOffset;
- (void)setLeftOffset:(int)nx;
- (int)topOffset;
- (void)setTopOffset:(int)nv;
@end
