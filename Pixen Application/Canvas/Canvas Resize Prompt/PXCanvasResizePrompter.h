//
//  PXCanvasResizePrompter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@class PXCanvasResizeView;
@protocol PXCanvasResizePrompterDelegate;

@interface PXCanvasResizePrompter : NSWindowController
{
  @private
	PXCanvasResizeView *_resizeView;
	NSTextField *_widthField, *_heightField;
	NSColorWell *_backgroundColorWell;
	
	id < PXCanvasResizePrompterDelegate > _delegate;
}

@property (nonatomic, assign) IBOutlet PXCanvasResizeView *resizeView;
@property (nonatomic, assign) IBOutlet NSTextField *widthField, *heightField;
@property (nonatomic, assign) IBOutlet NSColorWell *backgroundColorWell;

@property (nonatomic, assign) NSColor *backgroundColor;
@property (nonatomic, assign) NSSize currentSize;
@property (nonatomic, retain) NSImage *cachedImage;

@property (nonatomic, assign) id < PXCanvasResizePrompterDelegate > delegate;

- (void)promptInWindow:(NSWindow *)window;

- (IBAction)updateSize:(id)sender;
- (IBAction)updateBackgroundColor:(id)sender;

- (IBAction)displayHelp:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)useEnteredFrame:(id)sender;

@end


@protocol PXCanvasResizePrompterDelegate < NSObject >

- (void)prompter:(PXCanvasResizePrompter *)prompter didFinishWithSize:(NSSize)size
		position:(NSPoint)position backgroundColor:(NSColor *)color;

@end
