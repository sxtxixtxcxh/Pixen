//
//  PXImageBackground.h
//  Pixen
//

#import "PXMonotoneBackground.h"
@class NSButton;
@class NSImage;
@class NSTextField;

@interface PXImageBackground : PXMonotoneBackground 
{
  @private
	NSImage *image;
	IBOutlet NSTextField *imageNameField;
	IBOutlet NSButton *browseButton;
}

- (IBAction)configuratorBrowseForImageButtonClicked:(id)sender;
- (void)setImage:(NSImage *) anImage;

@end
