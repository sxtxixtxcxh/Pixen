//
//  PXAboutController.h
//  Pixen-XCode
//
//  Created by Andy Matuschak on Sun Aug 01 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import <AppKit/AppKit.h>

@class NSTextField, NSTextView, PXAboutPanel;

@interface PXAboutController : NSWindowController < NSWindowDelegate >
{
  @private
	PXAboutPanel *aboutPanel;
	IBOutlet NSTextView *creditsView;
	IBOutlet NSTextField *versionField;
}

+ (id)sharedAboutController;

- (void)showPanel:(id)sender;

@end
