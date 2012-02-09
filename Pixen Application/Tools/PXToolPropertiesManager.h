//
//  PXToolPropertiesManager.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

@class PXToolPropertiesController;

typedef enum {
	PXToolPropertiesSideLeft = 0,
	PXToolPropertiesSideRight
} PXToolPropertiesSide;

@interface PXToolPropertiesManager : NSWindowController
{
  @private
	PXToolPropertiesSide _side;
	PXToolPropertiesController *_propertiesController;
}

@property (nonatomic, readonly) PXToolPropertiesSide side;

@property (nonatomic, retain) PXToolPropertiesController *propertiesController;

+ (PXToolPropertiesManager *)leftToolPropertiesManager;
+ (PXToolPropertiesManager *)rightToolPropertiesManager;

- (id)initWithSide:(PXToolPropertiesSide)side;

@end
