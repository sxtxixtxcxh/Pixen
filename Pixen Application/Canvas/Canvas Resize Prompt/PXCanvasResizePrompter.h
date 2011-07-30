//
//  PXCanvasResizePrompter.h
//  Pixen
//

#import <AppKit/AppKit.h>

@class PXCanvasResizeView;

@interface PXCanvasResizePrompter : NSWindowController
{
  @private
	IBOutlet NSTextField *heightField, *widthField;
	IBOutlet PXCanvasResizeView *resizeView;
	IBOutlet NSColorWell *bgColorWell;
	NSImage *cachedImage;
	id delegate;
}

@property (nonatomic, assign) id delegate;

- (void)promptInWindow:(NSWindow *)window;

- (IBAction)cancel:(id)sender;
- (IBAction)updateBgColor:(id)sender;
- (IBAction)updateSize:(id)sender;
- (IBAction)useEnteredFrame:(id)sender;

- (void)setCurrentSize:(NSSize)size;
- (void)setCachedImage:(NSImage *)image;

- (NSTextField *)widthField;
- (NSTextField *)heightField;
- (PXCanvasResizeView *)resizeView;

- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)c;

@end


@interface NSObject(PXCanvasResizePrompterDelegate)

- (void)prompter:(PXCanvasResizePrompter *)aPrompter didFinishWithSize:(NSSize)size
		position:(NSPoint)position backgroundColor:(NSColor *)color;

@end
