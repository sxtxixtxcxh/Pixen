//
//  PXPatternEditorController.h
//  Pixen
//

#import <AppKit/AppKit.h>

@class PXPattern, PXPatternEditorView, PXSavedPatternMatrix;

@interface PXPatternEditorController : NSWindowController {
  @private
	PXPattern *pattern;
	PXPattern *oldPattern;
	NSString *toolName;
	IBOutlet PXPatternEditorView *view;
	IBOutlet NSScrollView *scrollView;
	PXSavedPatternMatrix *matrix;
	id delegate;
}

@property (nonatomic, copy) NSString *toolName;

@property (nonatomic, assign) id delegate;

- (void)setPattern:(PXPattern *)pattern;

- (IBAction)save:sender;
- (IBAction)load:sender;
- (IBAction)deleteSelected:sender;
- (IBAction)newPattern:sender;

@end

@interface NSObject(PXPatternEditorControllerDelegate)
- (void)patternEditor:(PXPatternEditorController *)ed finishedWithPattern:(PXPattern *)pat;
@end
