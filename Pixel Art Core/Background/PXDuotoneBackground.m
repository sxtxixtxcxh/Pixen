//
//  PXDuotoneBackground.m
//  Pixen
//

#import "PXDuotoneBackground.h"

@implementation PXDuotoneBackground

@synthesize backColor;

- (NSString *)nibName
{
	return @"PXDuotoneBackgroundConfigurator";
}

- (void)setConfiguratorEnabled:(BOOL)enabled
{
    [backWell setEnabled:enabled];
    [super setConfiguratorEnabled:enabled];
}

- (IBAction)configuratorBackColorChanged:(id)sender
{
	[self setBackColor:[sender color]];
	[self changed];
	
	self.cachedImage = nil;
}

- (void)setBackColor:(NSColor *)aColor
{
	backColor = aColor;
	
	if (aColor)
	{
		[backWell setColor:aColor];
	}
}

- (void)windowWillClose:(NSNotification *)notification
{
	[super windowWillClose:notification];
	
	if ([backWell isActive])
		[[NSColorPanel sharedColorPanel] close];
	
	[backWell deactivate];
}

- (id)init
{
	if ( ! ( self = [super init] ))
		return nil;
	
	[self setColor:[NSColor lightGrayColor]];
	[self setBackColor:[NSColor whiteColor]];
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	id copy = [super copyWithZone:zone];
	[copy setBackColor:backColor];
	
	return copy;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:backColor forKey:@"backColor"];
	[super encodeWithCoder:coder];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	[self setBackColor:[coder decodeObjectForKey:@"backColor"]];
	return self;
}

@end
