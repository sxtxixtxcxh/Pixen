//
//  PXMonotoneBackground.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXBackground.h"

@interface PXMonotoneBackground : PXBackground
{
    NSColorWell *_colorWell;
    NSColor *_color;
}

@property (nonatomic, assign) IBOutlet NSColorWell *colorWell;

@property (nonatomic, retain) NSColor *color;

- (IBAction)configuratorColorChanged:(id)sender;

@end
