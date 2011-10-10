//
//  PXAboutPanel.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@protocol PXAboutPanelDelegate;

@interface PXAboutPanel : NSPanel

@end


@protocol PXAboutPanelDelegate < NSWindowDelegate >

- (BOOL)handlesKeyDown:(NSEvent *)theEvent inWindow:(NSWindow *)window;

@end
