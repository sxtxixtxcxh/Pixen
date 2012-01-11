//
//  PXCanvasResizePrompter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@class PXCanvasResizeView;

@interface PXCanvasResizePrompter : NSWindowController
{
  @private
	PXCanvasResizeView *_resizeView;
	NSTextField *_widthField, *_heightField;
	NSColorWell *_backgroundColorWell;
	id _delegate;
}

@property (nonatomic, assign) IBOutlet PXCanvasResizeView *resizeView;
@property (nonatomic, assign) IBOutlet NSTextField *widthField, *heightField;
@property (nonatomic, assign) IBOutlet NSColorWell *backgroundColorWell;

@property (nonatomic, assign) NSColor *backgroundColor;

@property (nonatomic, assign) id delegate;

- (void)promptInWindow:(NSWindow *)window;

- (IBAction)updateSize:(id)sender;
- (IBAction)updateBackgroundColor:(id)sender;
- (IBAction)displayHelp:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)useEnteredFrame:(id)sender;

- (void)setCurrentSize:(NSSize)size;
- (void)setCachedImage:(NSImage *)image;

@end


@interface NSObject (PXCanvasResizePrompterDelegate)

- (void)prompter:(PXCanvasResizePrompter *)aPrompter didFinishWithSize:(NSSize)size
		position:(NSPoint)position backgroundColor:(NSColor *)color;

@end
