//
//  PXAboutWindowController.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@class PXAboutController, PXAboutPanel;

@interface PXAboutWindowController : NSWindowController < NSWindowDelegate >
{
  @private
	PXAboutPanel *_aboutPanel;
	PXAboutController *_viewController;
}

+ (id)sharedController;

@end
