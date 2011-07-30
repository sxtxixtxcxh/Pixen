//
//  PXCanvasResizePrompter.m
//  Pixen
//

#import "PXCanvasResizePrompter.h"

#import "PXCanvasResizeView.h"

@implementation PXCanvasResizePrompter

@synthesize delegate;

- (id)init
{
	if ( ! (self = [super initWithWindowNibName:@"PXCanvasResizePrompt"] ))
		return nil;
	
	return self;
}

- (void)promptInWindow:(NSWindow *)window
{
	if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-SenTest"])
		return;
	
	[resizeView setTopOffset:0];
	[resizeView setLeftOffset:0];
	
	[NSApp beginSheet:[self window]
	   modalForWindow:window
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}

- (NSColor *)backgroundColor
{
	return [resizeView backgroundColor];
}

- (void)setBackgroundColor:(NSColor *)c
{
	[bgColorWell setColor:c];
	[resizeView setBackgroundColor:c];
}

- (IBAction)updateBgColor:(id)sender
{
	[resizeView setBackgroundColor:[bgColorWell color]];
}

- (IBAction)useEnteredFrame:(id)sender
{
	[delegate prompter:self didFinishWithSize:[resizeView newSize]
			  position:[resizeView resultPosition]
	   backgroundColor:[bgColorWell color]];
	
	[NSApp endSheet:[self window]];
	[self close];
}

- (IBAction)cancel:(id)sender
{
	[NSApp endSheet:[self window]];
	[self close];
}

- (PXCanvasResizeView *)resizeView
{
	return resizeView;
}

- (NSTextField *)widthField
{
	return widthField;
}

- (NSTextField *)heightField
{
	return heightField;
}

- (IBAction)updateSize:(id)sender
{
	int width = [[self widthField] intValue];
	int height = [[self heightField] intValue];
	
	[resizeView setNewImageSize:NSMakeSize(width, height)];
}

- (void)setCurrentSize:(NSSize)size
{
	[[self widthField] setIntValue:size.width];
	[[self heightField] setIntValue:size.height];
	
	[resizeView setNewImageSize:size];
	[resizeView setOldImageSize:size];
}

- (IBAction)displayHelp:(id)sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"resize" inBook:@"Pixen Help"];
}

- (void)setCachedImage:(NSImage *)image
{
	[resizeView setCachedImage:image];
}

@end
