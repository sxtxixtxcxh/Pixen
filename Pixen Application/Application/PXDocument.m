//
//  PXDocument.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXDocument.h"

#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvasWindowController.h"

@implementation PXDocument

@synthesize windowController = _windowController;

- (void)dealloc
{
	[_windowController release];
	[super dealloc];
}

- (void)initWindowController { }

- (void)setWindowControllerData { }

- (NSString *)frameAutosaveName
{
	return [[self className] stringByAppendingString:[self displayName]];
}

- (void)makeWindowControllers
{
	[self initWindowController];
	
	[[self.windowController window] setFrameAutosaveName:[self frameAutosaveName]];
	[[self.windowController window] setFrameUsingName:[self frameAutosaveName]];
	
	[self addWindowController:self.windowController];
	[self setWindowControllerData];
	
	[self.windowController prepare];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXDocumentOpenedNotificationName
														object:self];
}

- (PXCanvas *)canvas
{
	return nil;
}

- (NSArray *)canvases
{
	return [NSArray arrayWithObject:[self canvas]];
}

- (BOOL)containsCanvas:(PXCanvas *)canvas
{
	return [[self canvases] containsObject:canvas];
}

- (void)close
{
	if ([[[self canvas] layers] count])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:PXDocumentWillCloseNotificationName
															object:self];
	}
	
	[super close];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXDocumentDidCloseNotificationName
														object:self];
}

- (void)setFileURL:(NSURL *)url
{
	[super setFileURL:url];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXDocumentChangedDisplayNameNotificationName
														object:self];
}

@end
