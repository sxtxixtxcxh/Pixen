//
//  PXMonotoneBackground.h
//  Pixen
//

#import "PXBackground.h"

@class NSColor, NSColorWell;

@interface PXMonotoneBackground : PXBackground
{
  @private
	NSColor *color;
	IBOutlet NSColorWell *colorWell;
}

@property (nonatomic, retain) NSColor *color;

- (IBAction)configuratorColorChanged:(id)sender;

@end
