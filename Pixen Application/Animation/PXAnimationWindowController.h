//
//  PXAnimationWindowController.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXAnimationPreview.h"
#import "PXCanvasWindowController.h"

@class PXAnimation, PXCel, PXFilmStripView;

@interface PXAnimationWindowController : PXCanvasWindowController < PXAnimationPreviewDataSource >
{
  @private
	PXAnimation *animation;
	IBOutlet NSSplitView *outerSplitView;
	IBOutlet PXFilmStripView *filmStrip;
	IBOutlet PXAnimationPreview *animationPreview;
	
	IBOutlet NSView *topSubview;
	
	IBOutlet NSButton *playPauseButton;
	
	PXCel *activeCel;
	NSInteger activeIndex;
}

- (void)setAnimation:anim;
- (void)activateCel:(PXCel *)cel;
- (IBAction)deleteCel:sender;
- (IBAction)duplicateCel:sender;
- (void)writeCelsAtIndices:(NSIndexSet *)indices toPasteboard:(NSPasteboard *)pboard;

@end
