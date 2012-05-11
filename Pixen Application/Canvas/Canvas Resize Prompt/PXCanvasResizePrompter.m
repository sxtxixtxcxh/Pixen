//
//  PXCanvasResizePrompter.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasResizePrompter.h"

#import "PXCanvasAnchorView.h"

@implementation PXCanvasResizePrompter

@synthesize widthField = _widthField, heightField = _heightField;
@synthesize backgroundColorWell = _backgroundColorWell, anchorView = _anchorView;
@synthesize oldSize = _oldSize;
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

- (IBAction)cancel:(id)sender
{
	[NSApp endSheet:[self window]];
	[self close];
}

- (IBAction)useEnteredFrame:(id)sender
{
	NSPoint position = [_anchorView topLeftPositionWithOldSize:_oldSize newSize:[self currentSize]];
	
	[_delegate canvasResizePrompter:self
				  didFinishWithSize:[self currentSize]
						   position:position
					backgroundColor:[[_backgroundColorWell color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
	
	[self cancel:nil];
}

@end
