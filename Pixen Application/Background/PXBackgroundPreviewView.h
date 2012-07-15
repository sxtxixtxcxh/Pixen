//
//  PXBackgroundPreviewView.h
//  Pixen
//

#import <Cocoa/Cocoa.h>

@interface PXBackgroundPreviewView : NSView
{
  @private
	NSRect functionalRect;
}

@property (nonatomic, strong) NSImage *image;

@end
