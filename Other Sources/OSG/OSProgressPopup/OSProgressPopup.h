//
//  OSProgressPopup.h
//  OSProgressPopup
//
//  Created by Andy Matuschak on 8/7/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OSProgressThread;

@interface OSProgressPopup : NSObject
{
  @private
	BOOL operationActive;
	IBOutlet NSTextField *statusField;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSWindow *window;
	
	NSOperationQueue *_workQueue;
	BOOL indeterminate;
}

// This method returns the singleton instance of the progress popup. Don't allocate your own; use this method.
+ (OSProgressPopup *)sharedProgressPopup;

// Use this method to begin a non-threaded operation with the progress popup.
- (void)beginOperationWithStatusText:(NSString *)statusText parentWindow:(NSWindow *)parentWindow;

- (void)endOperation;

- (void)setCanCancel:(BOOL)canCancel;
- (void)setStatusText:(NSString *)statusText;
- (void)setProgress:(double)progress;
- (void)setMaxProgress:(double)maxProgress;

@end
