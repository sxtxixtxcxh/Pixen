//
//  PXAnimationPreview.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

@class PXCel;

@interface PXAnimationPreview : NSView
{
	NSTimer *_animationTimer;
	PXCel *_currentCel;
	NSUInteger _currentIndex;
    id _dataSource;
}

@property (nonatomic, assign) IBOutlet id dataSource;

- (BOOL)isPlaying;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)playPause:(id)sender; // if it's paused, play. if it's playing, pause.
- (IBAction)stepForward:(id)sender;
- (IBAction)stepBackward:(id)sender;

- (void)reloadData;

@end


@interface NSObject (PXAnimationPreviewDataSource)

- (NSUInteger)numberOfCels;
- (id)celAtIndex:(NSUInteger)currentIndex;

- (NSTimeInterval)durationOfCelAtIndex:(NSUInteger)currentIndex;

@end
