//
//  PXShapeToolPropertiesController.h
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXToolPropertiesController.h"

@interface PXShapeToolPropertiesController : PXToolPropertiesController
{
  @private
	NSColor *fillColor;
	BOOL shouldFill;
	BOOL shouldUseMainColorForFill;
	int borderWidth;
}

@property (nonatomic, retain) NSColor *fillColor;
@property (nonatomic, assign) BOOL shouldFill;
@property (nonatomic, assign) BOOL shouldUseMainColorForFill;
@property (nonatomic, assign) int borderWidth;

@end
