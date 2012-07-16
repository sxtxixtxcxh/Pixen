//
//  PXAnimationWindowController.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXCanvasWindowController.h"
#import "PXScaleController.h"

@class PXAnimation, PXCel, PXFilmStripView;

@interface PXAnimationWindowController : PXCanvasWindowController < PXScaleControllerDelegate >
{
  @private
	PXCel *__weak activeCel;
	NSInteger activeIndex;
}

@property (nonatomic, weak) IBOutlet NSSplitView *outerSplitView;
@property (nonatomic, weak) IBOutlet PXFilmStripView *filmStrip;
@property (nonatomic, weak) IBOutlet NSView *topSubview;

@property (nonatomic, weak) PXAnimation *animation;

- (void)activateCel:(PXCel *)cel;
- (IBAction)newCel:(id)sender;
- (IBAction)deleteCel:sender;
- (IBAction)duplicateCel:sender;
- (void)writeCelsAtIndices:(NSIndexSet *)indices toPasteboard:(NSPasteboard *)pboard;

@end
