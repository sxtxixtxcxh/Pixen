//
//  PXBackgroundPreviewView.h
//  Pixen
//

#import <Cocoa/Cocoa.h>

@interface PXBackgroundPreviewView : NSView
{
  @private
	NSImage *image;
	NSRect functionalRect;
}

@property (nonatomic, retain) NSImage *image;

@end
