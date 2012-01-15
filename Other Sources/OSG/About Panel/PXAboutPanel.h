//
//  PXAboutPanel.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@protocol PXAboutPanelDelegate;

@interface PXAboutPanel : NSPanel

@end


@protocol PXAboutPanelDelegate < NSWindowDelegate >

- (BOOL)handlesKeyDown:(NSEvent *)theEvent inWindow:(NSWindow *)window;

@end
