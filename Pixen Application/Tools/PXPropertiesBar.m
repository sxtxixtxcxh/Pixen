//
//  PXPropertiesBar.m
//  Pixen
//
//  Created by Matt on 3/19/13.
//
//

#import "PXPropertiesBar.h"

@implementation PXPropertiesBar

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(setNeedsDisplay:)
												 name:NSWindowDidBecomeMainNotification
											   object:self.window];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(setNeedsDisplay:)
												 name:NSWindowDidResignMainNotification
											   object:self.window];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSColor *start;
	NSColor *end;
	
	if (self.window.isMainWindow) {
		start = [NSColor colorWithDeviceRed:218/255.0f green:218/255.0f blue:218/255.0f alpha:1.0f];
		end = [NSColor colorWithDeviceRed:176/255.0f green:176/255.0f blue:176/255.0f alpha:1.0f];
	}
	else {
		start = [NSColor colorWithDeviceRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
		end = [NSColor colorWithDeviceRed:218/255.0f green:218/255.0f blue:218/255.0f alpha:1.0f];
	}
	
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:end endingColor:start];
	[gradient drawInRect:[self bounds] angle:90.0f];
	
	if (self.window.isMainWindow)
		[[NSColor colorWithDeviceRed:128.0f/255 green:128.0f/255 blue:128.0f/255 alpha:1.0f] set];
	else
		[[NSColor colorWithDeviceRed:166.0f/255 green:166.0f/255 blue:166.0f/255 alpha:1.0f] set];
	
	NSRectFill(NSMakeRect(0.0f, 0.0f, NSWidth([self bounds]), 1.0f));
}

@end
