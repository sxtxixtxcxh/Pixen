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

@property (nonatomic, weak) IBOutlet NSCollectionView *collectionView;
@property (nonatomic, weak) IBOutlet NSScrollView *scrollView;
@property (nonatomic, weak) IBOutlet PXPatternEditorView *editorView;

+ (id)sharedController;

- (NSArrayController *)patternsController;

@end
