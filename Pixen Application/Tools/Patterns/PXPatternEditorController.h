//
//  PXPatternEditorController.h
//  Pixen
//

#import <AppKit/AppKit.h>

@class PXPattern, PXPatternEditorView;

@interface PXPatternEditorController : NSWindowController {
  @private
	PXPattern *_pattern;
	PXPattern *oldPattern;
	NSString *toolName;
	NSString *patternFileName;
	IBOutlet NSArrayController *patternsController;
	IBOutlet NSScrollView *scrollView;
	IBOutlet PXPatternEditorView *editorView;
	id delegate;
}

@property (nonatomic, copy) NSString *toolName;
@property (nonatomic, copy) NSString *patternFileName;

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
