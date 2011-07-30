//
//  PXPreviewResizeSizeView.h
//  Pixen
//

#import <AppKit/AppKit.h>


@interface PXPreviewResizeSizeView : NSView 
{
  @private
	NSAttributedString *scaleString;
	NSShadow *shadow;
}

- (BOOL)updateScale:(float)scale;
- (NSSize)scaleStringSize;

@end
