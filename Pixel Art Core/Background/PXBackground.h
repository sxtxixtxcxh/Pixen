//
//  PXBackground.h
//  Pixen
//

#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>

#import <AppKit/NSNibDeclarations.h>

@class PXCanvas;
@class NSString, NSAffineTransform, NSView, NSImage;

@interface PXBackground : NSViewController <NSCoding, NSCopying>
{
  @private
	NSString *name;
	NSSize cachedImageSize;
	NSImage *cachedImage;
}

@property (nonatomic, retain) NSImage *cachedImage;
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
