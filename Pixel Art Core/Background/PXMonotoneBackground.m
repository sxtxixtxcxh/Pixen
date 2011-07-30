//
//  PXMonotoneBackground.m
//  Pixen
//

#import "PXMonotoneBackground.h"

@implementation PXMonotoneBackground

@synthesize color;

- (NSString *)defaultName
{
	return NSLocalizedString(@"FLAT_BACKGROUND", @"Flat Background");
}

- (NSString *)nibName
{
	return @"PXMonotoneBackgroundConfigurator";
}

- (void)setConfiguratorEnabled:(BOOL)enabled
{
	[colorWell setEnabled:enabled];
}

- (IBAction)configuratorColorChanged:(id)sender
{
	[self setColor:[sender color]];
	[self changed];
	
	self.cachedImage = nil;
}

- (void)windowWillClose:(NSNotification *)notification
{
	if ([colorWell isActive])
		[[NSColorPanel sharedColorPanel] close];
	
	[colorWell deactivate];
}

- (id)init
{
	if ( ! ( self = [super init] ))
		return nil;
	
	color = [[NSColor whiteColor] retain];
	return self;
}

- (void)dealloc
{
	[self setColor:nil];
	[super dealloc];
}

- (void)setColor:(NSColor *)aColor
{
	[aColor retain];
	[color release];
	color = aColor;
	
	if (aColor)
	{
		[colorWell setColor:aColor];
	}
}

- (void)drawRect:(NSRect)rect withinRect:(NSRect)wholeRect
{
	[color set];
	NSRectFill(rect);
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:color forKey:@"color"];
    [super encodeWithCoder:coder];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	[self setColor:[coder decodeObjectForKey:@"color"]];
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	id copy = [super copyWithZone:zone];
	[copy setColor:color];
	return copy;
}

@end
