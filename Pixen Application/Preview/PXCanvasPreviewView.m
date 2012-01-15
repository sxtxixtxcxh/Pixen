//
//  PXCanvasPreviewView.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasPreviewView.h"

#import "PXCanvas_Backgrounds.h"

@implementation PXCanvasPreviewView

- (PXBackground *)mainBackground
{
	return [self.canvas mainPreviewBackground];
}

- (PXBackground *)alternateBackground
{
	return [self.canvas alternatePreviewBackground];
}

@end
