//
//  PXDuotoneBackground.h
//  Pixen
//

#import "PXMonotoneBackground.h"

@interface PXDuotoneBackground : PXMonotoneBackground

@property (nonatomic, weak) IBOutlet NSColorWell *backWell;

@property (nonatomic, strong) NSColor *backColor;

- (IBAction)configuratorBackColorChanged:(id)sender;

@end
