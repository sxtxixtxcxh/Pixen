//
//  PXPatternEditorView.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

@class PXPattern, PXGrid;

@interface PXPatternEditorView : NSView

@property (nonatomic, assign) PXPattern *pattern;

@property (nonatomic, assign) id delegate;

@end


@interface NSObject (PXPatternEditorViewDelegate)

- (void)patternView:(PXPatternEditorView *)pv changedPattern:(PXPattern *)pattern;

@end
