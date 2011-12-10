//
//  PXPatternEditorView.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

@class PXPattern, PXGrid;

@interface PXPatternEditorView : NSView
{
	PXGrid *_grid;
	BOOL _erasing;
    PXPattern *_pattern;
    id _delegate;
}

@property (nonatomic, assign) PXPattern *pattern;

@property (nonatomic, assign) id delegate;

@end


@interface NSObject (PXPatternEditorViewDelegate)

- (void)patternView:(PXPatternEditorView *)pv changedPattern:(PXPattern *)pattern;

@end
