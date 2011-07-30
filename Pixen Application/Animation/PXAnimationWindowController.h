
//
//  PXAnimationWindowController.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvasWindowController.h"
@class PXAnimation, PXCel, PXFilmStripView, PXAnimationPreview;
@interface PXAnimationWindowController : PXCanvasWindowController {
  @private
	PXAnimation *animation;
	IBOutlet NSSplitView *outerSplitView;
	IBOutlet PXFilmStripView *filmStrip;
	IBOutlet PXAnimationPreview *animationPreview;
	
	IBOutlet NSView *topSubview;
	unsigned oldMin, oldMax;
	
	IBOutlet NSButton *playPauseButton;
	
	PXCel *activeCel;
	NSInteger activeIndex;
}
- (void)setAnimation:anim;
- (void)activateCel:(PXCel *)cel;
- (IBAction)newCel:sender;
- (IBAction)deleteCel:sender;
- (IBAction)duplicateCel:sender;
- (void)writeCelsAtIndices:(NSIndexSet *)indices toPasteboard:(NSPasteboard *)pboard;
@end
