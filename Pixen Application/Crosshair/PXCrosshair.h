//
//  PXCrosshair.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

@class PXTool;

@interface PXCrosshair : NSObject
{
    NSPoint _cursorPosition;
}

@property (nonatomic, assign) NSPoint cursorPosition;
@property (nonatomic, readonly) NSColor *color;
@property (nonatomic, readonly) BOOL shouldDraw;

- (void)drawRect:(NSRect)drawingRect withTool:(PXTool *)tool tileOffset:(NSPoint)offset;

@end
