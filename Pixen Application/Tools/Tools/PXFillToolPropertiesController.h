//
//  PXFillToolPropertiesController.h
//  Pixen
//
//  Created by Andy Matuschak on 7/2/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXToolPropertiesController.h"

@interface PXFillToolPropertiesController : PXToolPropertiesController
{
  @private
	int tolerance;
	BOOL contiguous;
}

@property (nonatomic, assign) BOOL contiguous;
@property (nonatomic, assign) int tolerance;

- (IBAction)toleranceChanged:(id)sender;

@end
