//
//  PXAboutController.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@interface PXAboutController : NSWindowController < NSWindowDelegate >

@property (nonatomic, assign) IBOutlet NSTextView *creditsView;
@property (nonatomic, assign) IBOutlet NSTextField *versionField;

+ (id)sharedAboutController;

- (void)showPanel:(id)sender;

@end
