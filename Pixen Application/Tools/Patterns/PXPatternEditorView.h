//
//  PXPatternEditorView.h
//  Pixen
//

#import <AppKit/AppKit.h>

@class PXPattern, PXGrid;

@interface PXPatternEditorView : NSView {
  @private
	PXPattern *pattern;
	NSAffineTransform *transform;
	
	PXGrid *grid;
	
	NSPoint initialPoint;
	
	id delegate;
	
	BOOL erasing;
}

@property (nonatomic, assign) id delegate;

- (void)setPattern:(PXPattern *)newPattern;

- (NSSize)resizeToFitWidth:(float)frameSize;
- (NSSize)resizeToFitPattern:(PXPattern *)fitPattern;

@end


@interface NSObject(PXPatternEditorViewDelegate)
- (void)patternView:(PXPatternEditorView *)pv changedPattern:(PXPattern *)pat;
@end