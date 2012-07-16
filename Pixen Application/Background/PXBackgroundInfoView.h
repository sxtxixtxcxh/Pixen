/* PXBackgroundInfoView */

#import <Cocoa/Cocoa.h>

@class PXBackground, PXBackgroundPreviewView;

@interface PXBackgroundInfoView : NSView
{
  @private
	NSBezierPath *cachedEmptyPath;
	NSBezierPath *cachedBackgroundPath;
	NSPoint dragOrigin;
	
	NSImage *previewImage;
	BOOL isActiveDragTarget;
}

- (IBAction)nameChanged:(id)sender;
- (void)setPreviewImage:(NSImage *)img;

@property (nonatomic, weak) IBOutlet NSView *configuratorContainer;
@property (nonatomic, weak) IBOutlet id delegate;
@property (nonatomic, weak) IBOutlet PXBackgroundPreviewView *imageView;
@property (nonatomic, weak) IBOutlet NSTextField *nameField;

@property (nonatomic, weak) PXBackground *background;

@end


@interface NSObject(PXBackgroundInfoViewDelegate)

- (void)backgroundInfoView:(PXBackgroundInfoView *)infoView receivedBackground:(PXBackground *)bg;
- (void)dragFailedForInfoView:(PXBackgroundInfoView *)infoView;

@end
