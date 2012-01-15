//
//  PXImageBackground.h
//  Pixen
//

#import "PXMonotoneBackground.h"

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
