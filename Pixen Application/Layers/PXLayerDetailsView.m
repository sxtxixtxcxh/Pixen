//
//  PXLayerDetailsView.m
//  Pixen
//

#import "PXLayerDetailsView.h"

@implementation PXLayerDetailsView

@synthesize selected;

- (BOOL)acceptsFirstResponder
{
	return NO;
}

- (void)setSelected:(BOOL)state
{
	if (selected != state) {
		selected = state;
		[self setNeedsDisplay:YES];
	}
}

- (void)drawRect:(NSRect)rect
{
	if (selected) {
		[[NSColor alternateSelectedControlColor] set];
		NSRectFill(rect);
	}
}

@end
