/* PXBackgroundController */

#import <Cocoa/Cocoa.h>

@class PXBackgroundInfoView, PXBackgroundsTableView, PXBackground, OSStackedView, PXDefaultBackgroundTemplateView;

@interface PXBackgroundController : NSWindowController
{
  @private
	NSMutableArray *mainViews, *defaultsViews;
}

@property (nonatomic, weak) IBOutlet PXBackgroundInfoView *alternateBackgroundView;
@property (nonatomic, weak) IBOutlet PXBackgroundInfoView *mainBackgroundView;
@property (nonatomic, weak) IBOutlet OSStackedView *mainStack, *defaultsStack;

@property (nonatomic, weak) id delegate;

- (void)reloadData;
- (void)setPreviewImage:(NSImage *)img;
- (NSString *)pathForBackground:(PXBackground *)background;
- (void)saveBackground:(PXBackground *)background atPath:(NSString *)path;

@end


@interface NSObject (PXBackgroundControllerDelegate)

- (void)backgroundChanged:(NSNotification *)changed;

- (PXBackground *)mainBackground;
- (PXBackground *)alternateBackground;
- (void)setMainBackground:(PXBackground *)bg;
- (void)setAlternateBackground:(PXBackground *)bg;

- (PXBackground *)defaultMainBackground;
- (void)setDefaultMainBackground:(PXBackground *)bg;
- (PXBackground *)defaultAlternateBackground;
- (void)setDefaultAlternateBackground:(PXBackground *)bg;

@end


@interface PXBackgroundTemplateScrollView : NSScrollView

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)info;
- (NSDragOperation)draggingExited:(id <NSDraggingInfo>)info;

@end
