//
//  PXCanvasResizePrompter.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasResizePrompter.h"

#import "PXCanvasResizeView.h"

@implementation PXCanvasResizePrompter

@synthesize resizeView = _resizeView, widthField = _widthField, heightField = _heightField;
@synthesize backgroundColorWell = _backgroundColorWell;
@synthesize delegate = _delegate;

@dynamic backgroundColor;

- (id)init
{
	return [super initWithWindowNibName:@"PXCanvasResizePrompt"];
}

- (NSColor *)backgroundColor
{
	return [_resizeView backgroundColor];
}

- (void)setBackgroundColor:(NSColor *)color
{
	[_backgroundColorWell setColor:color];
	[_resizeView setBackgroundColor:color];
}

- (void)promptInWindow:(NSWindow *)window
{
	[_resizeView setTopOffset:0];
	[_resizeView setLeftOffset:0];
	
	[NSApp beginSheet:[self window]
	   modalForWindow:window
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}

- (IBAction)updateSize:(id)sender
{
	int width = [_widthField intValue];
	int height = [_heightField intValue];
	
	[_resizeView setNewImageSize:NSMakeSize(width, height)];
}

- (IBAction)updateBackgroundColor:(id)sender
{
	[_resizeView setBackgroundColor:[_backgroundColorWell color]];
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
	[self updateSize:nil];
	
	[_delegate prompter:self
	  didFinishWithSize:[_resizeView newImageSize]
			   position:[_resizeView resultPosition]
		backgroundColor:[_backgroundColorWell color]];
	
	[self cancel:nil];
}

- (void)setCurrentSize:(NSSize)size
{
	[_widthField setIntValue:size.width];
	[_heightField setIntValue:size.height];
	
	[_resizeView setNewImageSize:size];
	[_resizeView setOldImageSize:size];
}

- (void)setCachedImage:(NSImage *)image
{
	[_resizeView setCachedImage:image];
}

@end
