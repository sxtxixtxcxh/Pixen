//
//  PXWelcomeController.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface PXWelcomeController : NSWindowController

@property (nonatomic, assign) IBOutlet WebView *webView;

+ (id)sharedWelcomeController;

@end
