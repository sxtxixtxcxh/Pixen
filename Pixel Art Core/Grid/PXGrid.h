//
//  PXGrid.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXGrid : NSObject < NSCopying, NSCoding >
{
    NSSize _unitSize;
    NSColor *_color;
    BOOL _shouldDraw;
}
@property (nonatomic, assign) NSSize unitSize;
@property (nonatomic, retain) NSColor *color;
@property (nonatomic, assign) BOOL shouldDraw;

- (id)initWithUnitSize:(NSSize)unitSize color:(NSColor *)color shouldDraw:(BOOL)shouldDraw;

- (void)drawRect:(NSRect)drawingRect;

- (void)setDefaultParameters;

@end
