//
//  PXBackground.h
//  Pixen
//

@class PXCanvas;

@interface PXBackground : NSViewController <NSCoding, NSCopying>
{
  @private
	NSSize cachedImageSize;
}

@property (nonatomic, strong) NSImage *cachedImage;
@property (nonatomic, copy) NSString *name;

- (NSImage *)previewImageOfSize:(NSSize)size;
- (NSString *)defaultName;

- (void)setConfiguratorEnabled:(BOOL)enabled;
- (void)changed;

- (void)drawRect:(NSRect)rect withinRect:(NSRect)wholeRect;

- (void)drawRect:(NSRect)rect
      withinRect:(NSRect)wholeRect
   withTransform:(NSAffineTransform *)aTransform
		onCanvas:(PXCanvas *)aCanvas;

- (void)windowWillClose:(NSNotification *)note;

@end
