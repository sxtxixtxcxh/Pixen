//
//  PXCanvasResizePrompter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@class PXCanvasAnchorView;
@protocol PXCanvasResizePrompterDelegate;

@interface PXCanvasResizePrompter : NSWindowController

@property (nonatomic, weak) IBOutlet PXCanvasAnchorView *anchorView;
@property (nonatomic, weak) IBOutlet NSTextField *widthField, *heightField;
@property (nonatomic, weak) IBOutlet NSColorWell *backgroundColorWell;

@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, assign) NSSize oldSize;
@property (nonatomic, assign) NSSize currentSize;

@property (nonatomic, unsafe_unretained) id < PXCanvasResizePrompterDelegate > delegate;

- (void)promptInWindow:(NSWindow *)window;

- (IBAction)cancel:(id)sender;
- (IBAction)useEnteredFrame:(id)sender;

@end


@protocol PXCanvasResizePrompterDelegate < NSObject >

- (void)canvasResizePrompter:(PXCanvasResizePrompter *)prompter didFinishWithSize:(NSSize)size
					position:(NSPoint)position backgroundColor:(NSColor *)color;

@end
