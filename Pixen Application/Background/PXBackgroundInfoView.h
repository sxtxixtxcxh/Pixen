/* PXBackgroundInfoView */

#import <Cocoa/Cocoa.h>

@class PXBackground, PXBackgroundPreviewView;

@interface PXBackgroundInfoView : NSView
{
  @private
	IBOutlet NSView *configuratorContainer;
	IBOutlet id delegate;
	IBOutlet PXBackgroundPreviewView *imageView;
	IBOutlet NSTextField *nameField;
	NSBezierPath *cachedEmptyPath;
	NSBezierPath *cachedBackgroundPath;
	NSPoint dragOrigin;
	
	NSImage *previewImage;
	BOOL isActiveDragTarget;
}

- (IBAction)nameChanged:(id)sender;
- (void)setPreviewImage:(NSImage *)img;

@property (nonatomic, weak) PXBackground *background;

@property (nonatomic, strong, readonly) NSTextField *nameField;

@end


@interface NSObject(PXBackgroundInfoViewDelegate)

- (void)backgroundInfoView:(PXBackgroundInfoView *)infoView receivedBackground:(PXBackground *)bg;
- (void)dragFailedForInfoView:(PXBackgroundInfoView *)infoView;

@end
