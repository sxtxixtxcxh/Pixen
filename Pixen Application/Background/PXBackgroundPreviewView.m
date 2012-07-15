//
//  PXBackgroundPreviewView.m
//  Pixen
//

#import "PXBackgroundPreviewView.h"


@implementation PXBackgroundPreviewView

@synthesize image;

- (void)setImage:(NSImage *)im
{
	image = im;
	NSSize imageSize = [image size];
	NSSize viewSize = [self bounds].size;
	functionalRect.origin = NSZeroPoint;
	if (imageSize.width > imageSize.height)
	{
		if (imageSize.width > viewSize.width)
		{
			functionalRect.size.width = viewSize.width;
			functionalRect.size.height = ceilf(imageSize.height * (viewSize.width / imageSize.width));
		}
		else
			functionalRect.size = imageSize;
	}
	else
	{
		if (imageSize.height > viewSize.height)
		{
			functionalRect.size.height = viewSize.height;
			functionalRect.size.width = ceilf(imageSize.width * (viewSize.height / imageSize.height));
		}
		else
			functionalRect.size = imageSize;
	}
	
	if (NSWidth(functionalRect) < viewSize.width)
		functionalRect.origin.x = ceilf((viewSize.width / 2) - (NSWidth(functionalRect) / 2));
	if (NSHeight(functionalRect) < viewSize.height)
		functionalRect.origin.y = ceilf((viewSize.height / 2) - (NSHeight(functionalRect) / 2));
}

- (void)drawRect:(NSRect)rect
{
	[NSGraphicsContext saveGraphicsState];
	NSShadow *shadow = [[NSShadow alloc] init];
	NSRect rectBounds = NSIntersectionRect(NSInsetRect([self bounds], 5, 5), functionalRect);
	[shadow setShadowBlurRadius:5];
	[shadow setShadowOffset:NSMakeSize(0, -2)];
	[shadow setShadowColor:[NSColor colorWithDeviceWhite:0.2 alpha:1]];
	[[NSColor blackColor] setStroke];
	[[NSColor whiteColor] setFill];
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:rectBounds];
	[path setLineWidth:1.5];
	[path setLineJoinStyle:NSMiterLineJoinStyle];
	[shadow set];
	[path fill];
	[NSGraphicsContext restoreGraphicsState];
	[[self image] drawInRect:rectBounds
					fromRect:NSMakeRect(0, 0, [[self image] size].width, [[self image] size].height)
				   operation:NSCompositeSourceOver
					fraction:1];
}

@end
