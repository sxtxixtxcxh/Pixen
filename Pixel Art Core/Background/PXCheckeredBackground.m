//
//  PXCheckeredBackground.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCheckeredBackground.h"

@implementation PXCheckeredBackground

- (NSString *)defaultName
{
	return NSLocalizedString(@"CHECKERED_BACKGROUND", @"Checkered Background");
}

- (void)drawRect:(NSRect)rect withinRect:(NSRect)wholeRect
{
	[self.backColor set];
	NSRectFill(wholeRect);
	
	[self.color set];
	int i, j;
	BOOL drawForeground = NO;
	
	for (i = 0; i < wholeRect.size.width; i+=10)
	{
		drawForeground = i % 20 == 0;
		for (j = 0; j < wholeRect.size.height; j+=10)
		{
			if (drawForeground)
			{
				NSRectFill(NSMakeRect(wholeRect.origin.x+i, wholeRect.origin.y+j, 10, 10));
			}
			
			drawForeground = !drawForeground;
		}
	}
}

@end
