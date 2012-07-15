//
//  PXActionButton.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXActionButton.h"

@implementation PXActionButton

@synthesize image = _image;

- (void)drawRect:(NSRect)rect
{
	NSPoint point;
	
	NSSize rectSize = [self frame].size;
	float rectWidth = rectSize.width;
	float rectHeight = rectSize.height;
	
	NSSize imageSize = [_image size];
	float imageWidth = imageSize.width;
	float imageHeight = imageSize.height;
	
	[super drawRect:rect];
	
	point.x = (rectWidth - 18) / 2 - (imageWidth / 2) + 1;
	point.y = (rectHeight / 2) - ( imageHeight / 2) - 1;
	
	[self.image drawAtPoint:point
				   fromRect:NSMakeRect(0, 0, imageWidth, imageHeight)
				  operation:NSCompositeSourceOver
				   fraction:1.0];
}

@end
