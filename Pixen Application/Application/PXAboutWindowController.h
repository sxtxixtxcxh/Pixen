//
//  PXAboutWindowController.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface PXAboutWindowController : NSWindowController < NSWindowDelegate >

@property (nonatomic, weak) IBOutlet WebView *webView;

+ (id)sharedController;

@end
