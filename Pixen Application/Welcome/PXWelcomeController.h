//
//  PXWelcomeController.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface PXWelcomeController : NSWindowController < NSWindowRestoration >

@property (nonatomic, weak) IBOutlet WebView *webView;

+ (PXWelcomeController *)sharedWelcomeController;

@end
