//
//  PXCanvasPreviewView.m
//  Pixen
//
//  Created by Joe Osborn on 2007.11.13.
//  Copyright 2007 Open Sword Group. All rights reserved.
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
