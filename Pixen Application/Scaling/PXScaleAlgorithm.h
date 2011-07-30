//
//  PXScaleAlgorithm.h
//  Pixen
//

#import <AppKit/AppKit.h>

@class PXCanvas;
@class PXLayer;

@interface PXScaleAlgorithm : NSObject 
{
  @private
	IBOutlet NSView *parameterView;
}

+(id) algorithm;

- (NSString *)name;
- (NSString *)nibName;
- (NSString *)algorithmInfo;

- (BOOL)hasParameterView;
- (NSView *)parameterView;

- (BOOL)canScaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size;
- (void)scaleCanvas:(PXCanvas *)canvas toSize:(NSSize)size;

@end
