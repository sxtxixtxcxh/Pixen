//
//  PXDocument.m
//  Pixen
//
//  Created by Joe Osborn on 2007.11.17.
//  Copyright 2007 Pixen. All rights reserved.
//

#import "PXDocument.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvasWindowController.h"

@implementation PXDocument

@synthesize windowController;

- (void)dealloc
{
	[windowController release];	
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
	
	[[windowController window] setFrameAutosaveName:[self frameAutosaveName]];
	[[windowController window] setFrameUsingName:[self frameAutosaveName]];
	
    [self addWindowController:windowController];
	[self setWindowControllerData];
	
	[windowController prepare];
	
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

- (BOOL)containsCanvas:(PXCanvas *)c
{
	return [[self canvases] containsObject:c];
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
	[[NSNotificationCenter defaultCenter] postNotificationName:PXDocumentChangedDisplayNameNotificationName object:self];
}

@end
