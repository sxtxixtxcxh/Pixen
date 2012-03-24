//
//  PXCanvasResizePrompter.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasResizePrompter.h"

@implementation PXCanvasResizePrompter

@synthesize widthField = _widthField, heightField = _heightField;
@synthesize backgroundColorWell = _backgroundColorWell;
@synthesize delegate = _delegate;

@dynamic backgroundColor, currentSize;

- (id)init
{
	return [super initWithWindowNibName:@"PXCanvasResizePrompt"];
}

- (NSColor *)backgroundColor
{
	return [_backgroundColorWell color];
}

- (void)setBackgroundColor:(NSColor *)color
{
	[_backgroundColorWell setColor:color];
}

- (NSSize)currentSize
{
	return NSMakeSize([_widthField intValue], [_heightField intValue]);
}

- (void)setCurrentSize:(NSSize)size
{
	[_widthField setIntValue:size.width];
	[_heightField setIntValue:size.height];
}

- (void)promptInWindow:(NSWindow *)window
{
	[NSApp beginSheet:[self window]
	   modalForWindow:window
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}

- (IBAction)displayHelp:(id)sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"resize" inBook:@"Pixen Help"];
}

- (IBAction)cancel:(id)sender
{
	[NSApp endSheet:[self window]];
	[self close];
}

- (IBAction)useEnteredFrame:(id)sender
{
	[_delegate canvasResizePrompter:self
				  didFinishWithSize:[self currentSize]
						   position:NSZeroPoint
					backgroundColor:[[_backgroundColorWell color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
	
	[self cancel:nil];
}

@end
