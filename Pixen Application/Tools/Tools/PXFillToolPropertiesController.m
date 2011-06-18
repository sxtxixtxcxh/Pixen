//
//  PXFillToolPropertiesController.m
//  Pixen
//
//  Created by Andy Matuschak on 7/2/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXFillToolPropertiesController.h"

@implementation PXFillToolPropertiesController

@synthesize contiguous, tolerance;

- (NSString *)nibName
{
	return @"PXFillToolPropertiesView";
}

- (id)init
{
	self = [super init];
	
	self.tolerance = 0;
	self.contiguous = YES;
	
	return self;
}

- (IBAction)toleranceChanged:(id)sender
{
	self.tolerance = [sender intValue];
}

@end
