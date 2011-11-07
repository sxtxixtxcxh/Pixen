//
//  PXGrid.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@interface PXGrid : NSObject < NSCopying, NSCoding >

@property (nonatomic, assign) NSSize unitSize;
@property (nonatomic, retain) NSColor *color;
@property (nonatomic, assign) BOOL shouldDraw;

- (id)initWithUnitSize:(NSSize)unitSize color:(NSColor *)color shouldDraw:(BOOL)shouldDraw;

- (void)drawRect:(NSRect)drawingRect;

- (void)setDefaultParameters;

@end
