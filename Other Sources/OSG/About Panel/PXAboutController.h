//
//  PXAboutController.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@class PXAboutPanel;

@interface PXAboutController : NSWindowController < NSWindowDelegate >
{
	PXAboutPanel *_aboutPanel;
    NSTextView *_creditsView;
    NSTextField *_versionField;
}

@property (nonatomic, assign) IBOutlet NSTextView *creditsView;
@property (nonatomic, assign) IBOutlet NSTextField *versionField;

+ (id)sharedAboutController;

- (void)showPanel:(id)sender;

@end
