//
//  PXAnimationPreview.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXAnimationPreview.h"

#import "PXCel.h"

@interface PXAnimationPreview ()

- (void)stop;

@end


@implementation PXAnimationPreview

@synthesize dataSource = _dataSource;

- (void)refreshCurrentCel
{
	[_currentCel release];
	_currentCel = [[_dataSource celAtIndex:_currentIndex] retain];
	
	[self setNeedsDisplay:YES];
}

- (void)incrementFrame
{
	_currentIndex++;
	
	if (_currentIndex >= [_dataSource numberOfCels]) {
		_currentIndex = 0;
	}
	
	[self refreshCurrentCel];
}

- (BOOL)isPlaying
{
	return (_animationTimer != nil);
}

- (void)setDataSource:(id < PXAnimationPreviewDataSource >)ds
{
	if (_dataSource != ds) {
		[self stop];
		_dataSource = ds;
	}
}

- (void)incrementFromTimer:(NSTimer *)timer
{
	[self incrementFrame];
	
	[_animationTimer invalidate];
	[_animationTimer release];
	
	_animationTimer = [[NSTimer scheduledTimerWithTimeInterval:[_dataSource durationOfCelAtIndex:_currentIndex]
														target:self
													  selector:@selector(incrementFromTimer:)
													  userInfo:nil
													   repeats:NO] retain];
	
	[[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
}

- (void)stop
{
	[_currentCel release];
	_currentCel = nil;
	
	[self pause];
	
	_currentIndex = NSNotFound;
}

- (void)dealloc
{
	[_currentCel release];
	[_animationTimer invalidate];
	[_animationTimer release];
	
	[super dealloc];
}

- (void)drawRect:(NSRect)rect
{
	if (_currentCel == nil && _dataSource != nil && [_dataSource numberOfCels] > 0) {
		_currentIndex = 0;
		_currentCel = [[_dataSource celAtIndex:0] retain];
	}
	
	NSSize mySize = [self frame].size;
	NSSize theirSize = [_currentCel size];
	CGFloat myAspectRatio = mySize.height/mySize.width;
	CGFloat theirAspectRatio = theirSize.height/theirSize.width;
	NSRect aspectLockedRect;
	
	if (myAspectRatio > theirAspectRatio) {
		aspectLockedRect.size.width = mySize.width;
		aspectLockedRect.size.height = mySize.width*theirAspectRatio;
		aspectLockedRect.origin.x = 0;
		aspectLockedRect.origin.y = (mySize.height - aspectLockedRect.size.height) / 2.0f;
	} else {
		aspectLockedRect.size.width = mySize.height/theirAspectRatio;
		aspectLockedRect.size.height = mySize.height;
		aspectLockedRect.origin.x = (mySize.width - aspectLockedRect.size.width) / 2.0f;
		aspectLockedRect.origin.y = 0;
	}
	aspectLockedRect = NSInsetRect(aspectLockedRect, 1.0f, 1.0f);
	
	NSEraseRect(NSIntersectionRect(aspectLockedRect, rect));
	[[NSColor grayColor] set];
	NSRect frameRect = NSInsetRect(aspectLockedRect, -0.5f, -0.5f);
	
	NSFrameRect(frameRect);
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
	
	[_currentCel drawInRect:aspectLockedRect
				   fromRect:NSMakeRect(0.0f, 0.0f, [_currentCel size].width, [_currentCel size].height)
				  operation:NSCompositeSourceOver
				   fraction:1.0f];
}

- (void)play
{
	[self willChangeValueForKey:@"isPlaying"];
	[self incrementFromTimer:nil];
	[self didChangeValueForKey:@"isPlaying"];
}

- (void)pause
{
	[self willChangeValueForKey:@"isPlaying"];
	
	[_animationTimer invalidate];
	[_animationTimer release];
	_animationTimer = nil;
	
	[self didChangeValueForKey:@"isPlaying"];
}

- (IBAction)playPause:(id)sender
{
	if ([self isPlaying]) {
		[self pause];
	}
	else {
		[self play];
	}
}

- (IBAction)stepForward:(id)sender
{
	[self pause];
	[self incrementFrame];
}

- (IBAction)stepBackward:(id)sender
{
	[self pause];
	
	if (_currentIndex == 0) {
		_currentIndex = [_dataSource numberOfCels];
	}
	
	_currentIndex--;
	
	[self refreshCurrentCel];
}

- (void)reloadData
{
	[self stop];
	[self setNeedsDisplay:YES];
}

@end
