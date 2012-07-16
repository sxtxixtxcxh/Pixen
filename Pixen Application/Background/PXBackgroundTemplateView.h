//
//  PXBackgroundTemplateView.h
//  Pixen
//

#import <Cocoa/Cocoa.h>

@class PXBackground, PXBackgroundPreviewView;

@interface PXBackgroundTemplateView : NSView
{
  @private
	PXBackground *background;
	BOOL _highlighted;
}

@property (nonatomic, strong) PXBackground *background;

@property (weak, nonatomic) IBOutlet NSView *view;

@property (weak, nonatomic) IBOutlet NSTextField *templateNameField;
@property (weak, nonatomic) IBOutlet NSTextField *templateClassNameField;
@property (weak, nonatomic) IBOutlet PXBackgroundPreviewView *imageView;

@property (nonatomic, getter=isHighlighted, assign) BOOL highlighted;

@end
