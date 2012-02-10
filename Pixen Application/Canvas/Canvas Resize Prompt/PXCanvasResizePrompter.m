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

@dynamic backgroundColor, currentSize, cachedImage;

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

- (NSSize)currentSize
{
	return [_resizeView newImageSize];
}

- (void)setCurrentSize:(NSSize)size
{
	[_widthField setIntValue:size.width];
	[_heightField setIntValue:size.height];
	
	[_resizeView setNewImageSize:size];
	[_resizeView setOldImageSize:size];
}

- (NSImage *)cachedImage
{
	return [_resizeView cachedImage];
}

- (void)setCachedImage:(NSImage *)image
{
	[_resizeView setCachedImage:image];
}

- (void)promptInWindow:(NSWindow *)window
{
	[_resizeView setTopOffset:0.0f];
	[_resizeView setLeftOffset:0.0f];
	
	[NSApp beginSheet:[self window]
	   modalForWindow:window
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}

- (IBAction)updateSize:(id)sender
{
	[_resizeView setNewImageSize:NSMakeSize([_widthField intValue], [_heightField intValue])];
}

- (IBAction)updateBackgroundColor:(id)sender
{
	[_resizeView setBackgroundColor:[[_backgroundColorWell color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
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
			   position:[_resizeView resultantPosition]
		backgroundColor:[_resizeView backgroundColor]];
	
	[self cancel:nil];
}

@end
