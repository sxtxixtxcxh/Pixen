//
//  PXMonotoneBackground.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXMonotoneBackground.h"

@implementation PXMonotoneBackground

@synthesize colorWell = _colorWell, color = _color;

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
	[self.colorWell setEnabled:enabled];
}

- (IBAction)configuratorColorChanged:(id)sender
{
	[self setColor:[sender color]];
	[self changed];
	
	self.cachedImage = nil;
}

- (void)windowWillClose:(NSNotification *)notification
{
	if ([self.colorWell isActive])
		[[NSColorPanel sharedColorPanel] close];
	
	[self.colorWell deactivate];
}

- (id)init
{
	if ( ! ( self = [super init] ))
		return nil;
	
	self.color = [NSColor whiteColor];
	
	return self;
}

- (void)setColor:(NSColor *)aColor
{
	_color = aColor;
	
	if (aColor)
	{
		[self.colorWell setColor:aColor];
	}
}

- (void)drawRect:(NSRect)rect withinRect:(NSRect)wholeRect
{
	[self.color set];
	NSRectFill(rect);
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.color forKey:@"color"];
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
	[copy setColor:self.color];
	
	return copy;
}

@end
