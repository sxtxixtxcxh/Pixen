//
//  PXPatternEditorController.h
//  Pixen
//

#import <AppKit/AppKit.h>

@class PXPattern, PXPatternEditorView;

@interface PXPatternEditorController : NSWindowController < NSCollectionViewDelegate > {
  @private
	PXPattern *_pattern;
	NSString *toolName, *patternFileName;
	IBOutlet NSArrayController *patternsController;
	IBOutlet NSScrollView *scrollView;
	IBOutlet PXPatternEditorView *editorView;
	id delegate;
}

@property (nonatomic, copy) NSString *toolName;
@property (nonatomic, copy) NSString *patternFileName;

@property (nonatomic, assign) id delegate;

- (void)setPattern:(PXPattern *)pattern;

- (IBAction)newPattern:(id)sender;

- (void)reloadPatterns;

- (void)addPattern:(PXPattern *)pattern;
- (void)removePattern:(PXPattern *)pattern;

@end


@interface NSObject(PXPatternEditorControllerDelegate)

- (void)patternEditor:(PXPatternEditorController *)ed finishedWithPattern:(PXPattern *)pattern;

@end
