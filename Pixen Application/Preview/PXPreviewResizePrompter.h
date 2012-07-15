//
//  PXPreviewResizePrompter.h
//  Pixen
//
//  Created by Andy Matuschak on 6/11/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PXPreviewResizePrompter : NSWindowController
{
  @private
	IBOutlet NSTextField * zoomPercentage, * width, * height;
	NSSize canvasSize;
}

@property (nonatomic, weak) id delegate;

- (IBAction)resize:sender;
- (IBAction)cancel:sender;
- (IBAction)updateForm:sender;

- (void)setZoomFactor:(float)zoomFactor;
- (void)setCanvasSize:(NSSize)size;

- (void)promptInWindow:(NSWindow *)window;

@end


@interface NSObject(PXPreviewResizePrompterDelegate)

- (void)prompter:(PXPreviewResizePrompter *)p didFinishWithZoomFactor:(float)fac;

@end
