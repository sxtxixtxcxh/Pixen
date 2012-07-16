//
//  PXImageBackground.h
//  Pixen
//

#import "PXMonotoneBackground.h"

@interface PXImageBackground : PXMonotoneBackground 
{
  @private
	NSImage *image;
}

@property (nonatomic, weak) IBOutlet NSTextField *imageNameField;
@property (nonatomic, weak) IBOutlet NSButton *browseButton;

- (IBAction)configuratorBrowseForImageButtonClicked:(id)sender;
- (void)setImage:(NSImage *) anImage;

@end
