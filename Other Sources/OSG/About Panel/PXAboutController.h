//
//  PXAboutController.h
//  Pixen-XCode
//
//  Created by Andy Matuschak on Sun Aug 01 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import <AppKit/NSResponder.h>
#import <AppKit/NSNibDeclarations.h>

@class NSTimer, NSTextField, NSTextView;

@interface PXAboutController : NSResponder 
{
  @private
	id aboutPanel;
	NSPanel *panelInNib;
	IBOutlet NSTextView *credits;
	IBOutlet NSTextField *version;
}

+ (id)sharedAboutController;
- (void)showPanel:(id)sender;

@end
