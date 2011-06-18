//
//  PXToolPropertiesManager.h
//  Pixen
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import <AppKit/AppKit.h>

@class PXToolPropertiesController;

typedef enum {
	PXToolPropertiesSideLeft = 0,
	PXToolPropertiesSideRight
} PXToolPropertiesSide;

@interface PXToolPropertiesManager : NSWindowController
{
  @private
	PXToolPropertiesController *_propertiesController;
	PXToolPropertiesSide _side;
}

@property (nonatomic, readonly) PXToolPropertiesSide side;
@property (nonatomic, retain) PXToolPropertiesController *propertiesController;

+ (PXToolPropertiesManager *)leftToolPropertiesManager;
+ (PXToolPropertiesManager *)rightToolPropertiesManager;

- (id)initWithSide:(PXToolPropertiesSide)aSide;

@end
