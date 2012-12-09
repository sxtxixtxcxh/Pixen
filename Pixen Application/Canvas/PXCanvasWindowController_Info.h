//
//  PXCanvasWindowController_Info.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasWindowController.h"
#import "PXColor.h"

@interface PXCanvasWindowController (Info) < NSToolbarDelegate >

- (void)setCanvasSize:(NSSize)size;
- (void)updateInfoButtonTitle;

@end
