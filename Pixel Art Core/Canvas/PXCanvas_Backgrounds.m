//
//  PXCanvas_Backgrounds.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXCanvas_Backgrounds.h"

#import "PXBackgrounds.h"
#import "PXBackgroundConfig.h"

@implementation PXCanvas (Backgrounds)

@dynamic mainBackground, alternateBackground, mainPreviewBackground, alternatePreviewBackground;

- (PXBackground *)mainBackground
{
	return [bgConfig mainBackground];   
}

- (void)setMainBackground:(PXBackground *)bg
{
	[bgConfig setMainBackground:bg];
}

- (PXBackground *)alternateBackground
{
	return [bgConfig alternateBackground];
}

- (void)setAlternateBackground:(PXBackground *)bg
{
	[bgConfig setAlternateBackground:bg];
}

- (PXBackground *)mainPreviewBackground
{
	return [bgConfig mainPreviewBackground];
}

- (void)setMainPreviewBackground:(PXBackground *)bg
{
	[bgConfig setMainPreviewBackground:bg];
}

- (PXBackground *)alternatePreviewBackground
{
	return [bgConfig alternatePreviewBackground];
}

- (void)setAlternatePreviewBackground:(PXBackground *)bg
{
	[bgConfig setAlternatePreviewBackground:bg];
}

@end
