//
//  PXPatternEditorView.h
//  Pixen
//

#import <AppKit/AppKit.h>

@class PXPattern, PXGrid;

@interface PXPatternEditorView : NSView {
  @private
	PXPattern *pattern;
	PXGrid *grid;
	
	id delegate;
	
	BOOL erasing;
}

@property (nonatomic, assign) id delegate;

- (void)setPattern:(PXPattern *)newPattern;

@end


@interface NSObject(PXPatternEditorViewDelegate)

- (void)patternView:(PXPatternEditorView *)pv changedPattern:(PXPattern *)pattern;

@end
