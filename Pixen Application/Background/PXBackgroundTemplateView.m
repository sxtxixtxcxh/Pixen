//
//  PXBackgroundTemplateView.m
//  Pixen
//

#import "PXBackgroundTemplateView.h"

#import "PXBackgroundPreviewView.h"
#import "PXBackgrounds.h"

@implementation PXBackgroundTemplateView

@synthesize background, templateNameField, templateClassNameField, imageView;
@synthesize highlighted = _highlighted;

- (id)initWithFrame:(NSRect)frame
{
	if(!(self = [super initWithFrame:frame])) { return nil; }
	[NSBundle loadNibNamed:@"PXBackgroundTemplateView" owner:self];
    [self setAutoresizesSubviews:NO];
	[self addSubview:view];
	return self;
}

- (id)init
{
	if ( ! (self = [self initWithFrame:NSMakeRect(0, 0, 0, 45)] ) ) 
		return nil;
	return self;
}

- (void)setFrame:(NSRect)newFrame
{
	[super setFrame:newFrame];
	[view setFrameSize:[self frame].size];
}

- (void)resizeWithOldSuperviewSize:(NSSize)size
{
	[self setFrameSize:NSMakeSize(NSWidth([[self superview] visibleRect]), [self frame].size.height)];
}

- (void)resizeSubviewsWithOldSize:(NSSize)size
{
	[view setFrameSize:[self frame].size];
}

- (void)setBackground:(PXBackground *)bg
{
	background = bg;
	if(!bg) { return; }
	[imageView setImage:[background previewImageOfSize:[imageView bounds].size]];
	[imageView display];
	[templateClassNameField setStringValue:[bg defaultName]];
	[templateNameField setStringValue:[bg name]];
}

- (void)setHighlighted:(BOOL)highlighted
{
	if (_highlighted != highlighted) {
		_highlighted = highlighted;
		
		if (highlighted)
		{
			[templateClassNameField setTextColor:[NSColor whiteColor]];
			[templateNameField setTextColor:[NSColor whiteColor]];
		}
		else
		{
			[templateClassNameField setTextColor:[NSColor disabledControlTextColor]];
			[templateNameField setTextColor:[NSColor blackColor]];
		}
	}
}

@end
