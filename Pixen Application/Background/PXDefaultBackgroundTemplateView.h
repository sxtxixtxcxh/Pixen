//
//  PXDefaultBackgroundTemplateView.h
//  Pixen
//

#import <Cocoa/Cocoa.h>
#import "PXBackgroundTemplateView.h"

@interface PXDefaultBackgroundTemplateView : PXBackgroundTemplateView {
  @private
	NSString *backgroundTypeText;
	BOOL highlighted;
	BOOL activeDragTarget;
}

@property (nonatomic, retain) NSString *backgroundTypeText;

- (void)setActiveDragTarget:(BOOL)activeDragTarget;

@end
