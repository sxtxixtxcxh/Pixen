//
//  PXInfoPanelController.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXColor.h"

@interface PXInfoPanelController : NSWindowController

@property (nonatomic, weak) IBOutlet NSTextField *cursorX;
@property (nonatomic, weak) IBOutlet NSTextField *cursorY;
@property (nonatomic, weak) IBOutlet NSTextField *width;
@property (nonatomic, weak) IBOutlet NSTextField *height;
@property (nonatomic, weak) IBOutlet NSTextField *red;
@property (nonatomic, weak) IBOutlet NSTextField *green;
@property (nonatomic, weak) IBOutlet NSTextField *blue;
@property (nonatomic, weak) IBOutlet NSTextField *alpha;
@property (nonatomic, weak) IBOutlet NSTextField *hex;

@property (nonatomic, assign) NSPoint draggingOrigin;

+ (id)sharedInfoPanelController;

- (void)setCursorPosition:(NSPoint)point;
- (void)setColorInfo:(PXColor)color;
- (void)setCanvasSize:(NSSize)size;

- (void)setNoColorInfo;

@end
