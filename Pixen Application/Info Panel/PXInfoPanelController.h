//
//  PXInfoPanelController.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXInfoPanelController : NSWindowController
{
    NSTextField *_cursorX;
    NSTextField *_cursorY;
    NSTextField *_width;
    NSTextField *_height;
    NSTextField *_red;
    NSTextField *_green;
    NSTextField *_blue;
    NSTextField *_alpha;
    NSTextField *_hex;
    
    NSPoint _draggingOrigin;
}

@property (nonatomic, assign) IBOutlet NSTextField *cursorX;
@property (nonatomic, assign) IBOutlet NSTextField *cursorY;
@property (nonatomic, assign) IBOutlet NSTextField *width;
@property (nonatomic, assign) IBOutlet NSTextField *height;
@property (nonatomic, assign) IBOutlet NSTextField *red;
@property (nonatomic, assign) IBOutlet NSTextField *green;
@property (nonatomic, assign) IBOutlet NSTextField *blue;
@property (nonatomic, assign) IBOutlet NSTextField *alpha;
@property (nonatomic, assign) IBOutlet NSTextField *hex;

@property (nonatomic, assign) NSPoint draggingOrigin;

+ (id)sharedInfoPanelController;

- (void)setCursorPosition:(NSPoint)point;
- (void)setColorInfo:(NSColor *)color;
- (void)setCanvasSize:(NSSize)size;

@end
