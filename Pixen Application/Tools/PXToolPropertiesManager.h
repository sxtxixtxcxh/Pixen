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

@property (nonatomic, readonly) PXToolPropertiesSide side;

@property (nonatomic, strong) PXToolPropertiesController *propertiesController;

+ (PXToolPropertiesManager *)leftToolPropertiesManager;
+ (PXToolPropertiesManager *)rightToolPropertiesManager;

- (id)initWithSide:(PXToolPropertiesSide)side;

@end
