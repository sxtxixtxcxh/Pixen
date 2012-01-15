//
//  PXFillToolPropertiesController.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXFillToolPropertiesController.h"

@implementation PXFillToolPropertiesController

@synthesize contiguous = _contiguous, tolerance = _tolerance;

- (NSString *)nibName
{
	return @"PXFillToolPropertiesView";
}

- (id)init
{
	self = [super init];
	if (self) {
		self.tolerance = 0;
		self.contiguous = YES;
	}
	return self;
}

- (IBAction)toleranceChanged:(id)sender
{
	self.tolerance = [sender intValue];
}

@end
