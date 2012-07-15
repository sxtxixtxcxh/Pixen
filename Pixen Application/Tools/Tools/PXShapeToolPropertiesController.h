//
//  PXShapeToolPropertiesController.h
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXToolPropertiesController.h"

@interface PXShapeToolPropertiesController : PXToolPropertiesController

@property (nonatomic, strong) NSColor *fillColor;
@property (nonatomic, assign) BOOL shouldFill;
@property (nonatomic, assign) BOOL shouldUseMainColorForFill;
@property (nonatomic, assign) int borderWidth;

@end
