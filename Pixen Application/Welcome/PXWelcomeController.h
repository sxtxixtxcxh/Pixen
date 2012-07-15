//
//  PXWelcomeController.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface PXWelcomeController : NSWindowController

@property (nonatomic, weak) IBOutlet WebView *webView;

+ (id)sharedWelcomeController;

@end
