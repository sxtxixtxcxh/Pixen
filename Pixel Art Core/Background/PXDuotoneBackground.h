//
//  PXDuotoneBackground.h
//  Pixen
//

#import "PXMonotoneBackground.h"

@interface PXDuotoneBackground : PXMonotoneBackground 
{
  @private
	NSColor *backColor;
	IBOutlet NSColorWell *backWell;
}

@property (nonatomic, retain) NSColor *backColor;

- (IBAction)configuratorBackColorChanged:(id)sender;

@end
