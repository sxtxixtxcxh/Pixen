//
//  PXEyedropperToolPropertiesController.h
//  Pixen
//
//  Created by Andy Matuschak on 7/8/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXToolPropertiesController.h"

typedef enum _PXEyedropperColorSourceType {
	PXMergedLayersColorSource,
	PXActiveLayerColorSource
} PXEyedropperColorSourceType;

typedef enum _PXToolButtonType {
	PXLeftButtonTool,
	PXRightButtonTool
} PXToolButtonType;

@interface PXEyedropperToolPropertiesController : PXToolPropertiesController
{
  @private
	PXEyedropperColorSourceType colorSource;
	PXToolButtonType buttonType;
}

@property (nonatomic, weak) IBOutlet NSMatrix *targetMatrix;

@property (nonatomic, assign) PXToolButtonType buttonType;

- (PXEyedropperColorSourceType)colorSource;

- (IBAction)colorSourceChanged:(id)sender;
- (IBAction)targetChanged:(id)sender;

@end
