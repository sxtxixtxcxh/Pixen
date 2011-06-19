//
//  PXEyedropperToolPropertiesController.m
//  Pixen
//
//  Created by Andy Matuschak on 7/8/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXEyedropperToolPropertiesController.h"

@implementation PXEyedropperToolPropertiesController

@synthesize buttonType;

- (id)init
{
	self = [super init];
	colorSource = PXMergedLayersColorSource;
	return self;
}

- (void)setButtonType:(PXToolButtonType)type
{
	buttonType = type;
	
	if (targetMatrix)
		[targetMatrix selectCellAtRow:type column:0];
}

- (void)awakeFromNib
{
	[targetMatrix selectCellAtRow:buttonType column:0];
}

- (NSString *)nibName
{
    return @"PXEyedropperToolPropertiesView";
}

- (PXEyedropperColorSourceType)colorSource
{
	return colorSource;
}

- (IBAction)colorSourceChanged:(id)sender
{
	colorSource = ([[sender selectedCell] tag]) ? PXActiveLayerColorSource : PXMergedLayersColorSource;
}

- (IBAction)targetChanged:(id)sender
{
	self.buttonType = ([[sender selectedCell] tag]) ? PXRightButtonTool : PXLeftButtonTool;
}

@end
