//
//  PXAboutController.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXAboutController : NSViewController
{
  @private
	NSTextView *_creditsView;
	NSTextField *_versionField;
}

@property (nonatomic, assign) IBOutlet NSTextView *creditsView;
@property (nonatomic, assign) IBOutlet NSTextField *versionField;

@end
