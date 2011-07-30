//
//  PXAnimationPreview.h
//  PXAnimationPreview
//
//  Created by Ian Henderson on 09.08.05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PXCel;

@interface PXAnimationPreview : NSView {
  @private
	NSTimer *animationTimer;
	PXCel *currentCel;
	int currentIndex;
	IBOutlet id dataSource;
}

- (BOOL)isPlaying;

- (IBAction)play:sender;
- (IBAction)pause:sender;
- (IBAction)playPause:sender; // if it's paused, play.  if it's playing, pause.
- (IBAction)stepForward:sender;
- (IBAction)stepBackward:sender;
- (void)reloadData;
- (void)setDataSource:ds;

@end

@interface NSObject(PXAnimationPreviewDataSource)

- (int)numberOfCels;
- (id)celAtIndex:(NSUInteger)currentIndex;
- (NSTimeInterval)durationOfCelAtIndex:(NSUInteger)currentIndex;

@end
