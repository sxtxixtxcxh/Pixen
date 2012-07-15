//
//  PXShapeToolPropertiesController.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXShapeToolPropertiesController.h"

@implementation PXShapeToolPropertiesController

@synthesize fillColor, shouldFill, shouldUseMainColorForFill, borderWidth;

- (id)init
{
	self = [super init];
	self.shouldUseMainColorForFill = YES;
	self.borderWidth = 1;
	self.fillColor = [[NSColor blackColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	return self;
}

- (NSString *)nibName
{
	return @"PXShapeToolPropertiesView";
}

@end
