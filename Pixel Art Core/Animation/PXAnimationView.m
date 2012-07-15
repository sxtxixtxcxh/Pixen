//
//  PXAnimationView.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXAnimationView.h"

#import "PXCanvas_Modifying.h"
#import "PXDocumentController.h"

@implementation PXAnimationView

@synthesize previousCelImage = _previousCelImage;

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	if (![[NSDocumentController sharedDocumentController] showsPreviousCelOverlay]) { return; }
	if (!self.previousCelImage)
		return;
	
	[self.previousCelImage drawInRect:rect fromRect:[self convertFromViewToCanvasRect:rect] operation:NSCompositeSourceOver fraction:0.33];
}

@end
