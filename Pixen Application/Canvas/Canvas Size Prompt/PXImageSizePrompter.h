//
//  PXImageSizePrompter.h
//  Pixen
//

@class PXManagePresetsController, PXNamePrompter, PXNSImageView;

@interface PXImageSizePrompter : NSWindowController < NSWindowDelegate >
{
  @private
	PXNamePrompter *prompter;
	PXManagePresetsController *manageWC;
	
	NSInteger _width, _height;
	NSColor *backgroundColor;
	
	NSImage *image;
	NSTimer *animationTimer;
	NSSize initialSize;
	NSSize targetSize;
	float animationFraction;
	NSRect initialHeightIndicatorFrame;
	NSRect initialWidthIndicatorFrame;
	BOOL accepted;
}

@property (nonatomic, weak) IBOutlet PXNSImageView *preview;
@property (nonatomic, weak) IBOutlet NSView *widthIndicator, *heightIndicator;
@property (nonatomic, weak) IBOutlet NSPopUpButton *presetsButton;

@property (nonatomic, weak) IBOutlet NSTextField *promptField;

@property (nonatomic, readonly) NSSize size;

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong) NSColor *backgroundColor;

- (BOOL)runModal;

- (IBAction)sizeChanged:(id)sender;
- (IBAction)changedColor:(id)sender;

- (IBAction)useEnteredSize:(id)sender;
- (IBAction)cancel:(id)sender;

@end
