//
//  PXImageSizePrompter.h
//  Pixen
//

@class PXManagePresetsController, PXNamePrompter, PXNSImageView;

@interface PXImageSizePrompter : NSWindowController < NSWindowDelegate >
{
  @private
	IBOutlet PXNSImageView *preview;
	IBOutlet NSView *widthIndicator, *heightIndicator;
	IBOutlet NSPopUpButton *presetsButton;
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

@property (nonatomic, assign) IBOutlet NSTextField *promptField;

@property (nonatomic, readonly) NSSize size;

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, retain) NSColor *backgroundColor;

- (BOOL)runModal;

- (IBAction)sizeChanged:(id)sender;
- (IBAction)changedColor:(id)sender;

- (IBAction)useEnteredSize:(id)sender;
- (IBAction)cancel:(id)sender;

@end
