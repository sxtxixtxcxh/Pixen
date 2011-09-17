//
//  PXLayerDetailsView.h
//  Pixen
//

#import <Cocoa/Cocoa.h>

@interface PXLayerDetailsView : NSView {
  @private
	BOOL selected;
}

@property (nonatomic, assign) BOOL selected;

@end
