//
//  PXWelcomeController.h
//  Pixen
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface PXWelcomeController : NSWindowController
{
  @private
	WebView *webView;
}

@property (assign) IBOutlet WebView *webView;

+ (id)sharedWelcomeController;

@end
