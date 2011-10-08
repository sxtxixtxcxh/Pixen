//
//  PXCanvasPrintView.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXCanvasPrintView.h"

#import "PXCanvas.h"
#import "PXCanvas_Drawing.h"

@implementation PXCanvasPrintView {
	PXCanvas *_canvas;
}

+ (id)viewForCanvas:(PXCanvas *)aCanvas
{
	return [[[self alloc] initWithCanvas:aCanvas] autorelease];	
}

- (id)initWithCanvas:(PXCanvas *)aCanvas
{
	self = [super initWithFrame:NSMakeRect(0, 0, [aCanvas size].width, [aCanvas size].height)];
	_canvas = [aCanvas retain];
	return self;
}

- (void)dealloc
{
	[_canvas release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect 
{
	//find and apply the proper transform for the paper size
	NSPrintInfo *printInfo = [[NSPrintOperation currentOperation] printInfo];
	float scale = [[[printInfo dictionary] objectForKey:NSPrintScalingFactor] 
		floatValue];
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform scaleXBy:scale yBy:scale];
	[transform concat];
	[_canvas drawRect:rect];
	[transform invert];
	[transform concat];
}

@end
