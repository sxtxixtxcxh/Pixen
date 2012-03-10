//
//  PXAboutWindowController.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface PXAboutWindowController : NSWindowController < NSWindowDelegate >
{
  @private
	WebView *_webView;
}

@property (nonatomic, assign) IBOutlet WebView *webView;

+ (id)sharedController;

@end
