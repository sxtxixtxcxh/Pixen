//
//  PXMonotoneBackground.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXBackground.h"

@interface PXMonotoneBackground : PXBackground

@property (nonatomic, weak) IBOutlet NSColorWell *colorWell;

@property (nonatomic, strong) NSColor *color;

- (IBAction)configuratorColorChanged:(id)sender;

@end
