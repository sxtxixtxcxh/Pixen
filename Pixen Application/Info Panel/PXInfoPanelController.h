//
//  PXInfoPanelController.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@interface PXInfoPanelController : NSWindowController

@property (nonatomic, retain) IBOutlet NSTextField *cursorX;
@property (nonatomic, retain) IBOutlet NSTextField *cursorY;
@property (nonatomic, retain) IBOutlet NSTextField *width;
@property (nonatomic, retain) IBOutlet NSTextField *height;
@property (nonatomic, retain) IBOutlet NSTextField *red;
@property (nonatomic, retain) IBOutlet NSTextField *green;
@property (nonatomic, retain) IBOutlet NSTextField *blue;
@property (nonatomic, retain) IBOutlet NSTextField *alpha;
@property (nonatomic, retain) IBOutlet NSTextField *hex;

@property (nonatomic, assign) NSPoint draggingOrigin;

+ (id)sharedInfoPanelController;

- (void)setCursorPosition:(NSPoint)point;
- (void)setColorInfo:(NSColor *)color;
- (void)setCanvasSize:(NSSize)size;

@end
