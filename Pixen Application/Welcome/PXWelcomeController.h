//
//  PXWelcomeController.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface PXWelcomeController : NSWindowController
{
  @private
	WebView *_webView;
}

@property (nonatomic, assign) IBOutlet WebView *webView;

+ (id)sharedWelcomeController;

@end
