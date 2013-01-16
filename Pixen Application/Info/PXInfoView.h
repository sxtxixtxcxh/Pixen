//
//  PXInfoView.h
//  Pixen
//
//  Copyright 2013 Pixen Project. All rights reserved.
//

#import "PXColor.h"

@interface PXInfoView : NSView

@property (nonatomic, assign) BOOL hasColor;

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;

@property (nonatomic, assign) NSInteger cursorX;
@property (nonatomic, assign) NSInteger cursorY;

@property (nonatomic, assign) PXColor color;

@end
