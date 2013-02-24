//
//  PXPatternEditorController.h
//  Pixen
//

@class PXPattern, PXPatternEditorView;

@interface PXPatternEditorController : NSWindowController < NSCollectionViewDelegate >
{
  @private
	PXPattern *_pattern;
}

@property (nonatomic, strong) IBOutlet NSArrayController *patternsController;
@property (nonatomic, weak) IBOutlet NSScrollView *scrollView;
@property (nonatomic, weak) IBOutlet PXPatternEditorView *editorView;

+ (id)sharedController;

@end
