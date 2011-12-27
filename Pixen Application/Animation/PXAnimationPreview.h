//
//  PXAnimationPreview.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@class PXCel;
@protocol PXAnimationPreviewDataSource;

@interface PXAnimationPreview : NSView
{
  @private
	NSTimer *_animationTimer;
	PXCel *_currentCel;
	NSUInteger _currentIndex;
	id < PXAnimationPreviewDataSource > _dataSource;
}

@property (nonatomic, assign) IBOutlet id < PXAnimationPreviewDataSource > dataSource;

- (BOOL)isPlaying;

- (void)play;
- (void)pause;

- (IBAction)playPause:(id)sender; // if it's paused, play. if it's playing, pause.
- (IBAction)stepForward:(id)sender;
- (IBAction)stepBackward:(id)sender;

- (void)reloadData;

@end


@protocol PXAnimationPreviewDataSource < NSObject >

- (NSUInteger)numberOfCels;
- (id)celAtIndex:(NSUInteger)currentIndex;

- (NSTimeInterval)durationOfCelAtIndex:(NSUInteger)currentIndex;

@end
