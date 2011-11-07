//
//  PXToolPropertiesManager.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

@class PXToolPropertiesController;

typedef enum {
	PXToolPropertiesSideLeft = 0,
	PXToolPropertiesSideRight
} PXToolPropertiesSide;

@interface PXToolPropertiesManager : NSWindowController

@property (nonatomic, readonly) PXToolPropertiesSide side;

@property (nonatomic, retain) PXToolPropertiesController *propertiesController;

+ (PXToolPropertiesManager *)leftToolPropertiesManager;
+ (PXToolPropertiesManager *)rightToolPropertiesManager;

- (id)initWithSide:(PXToolPropertiesSide)aSide;

@end
