//
//  PXDocument.m
//  Pixen
//
//  Created by Joe Osborn on 2007.11.17.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PXDocument.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvasWindowController.h"

@implementation PXDocument

- init
{
	[super init];
	return self;
}

- (void)dealloc
{
	[[self windowControllers] makeObjectsPerformSelector:@selector(close)];
	[self removeWindowController:windowController];
	
	[super dealloc];
}

- (void)initWindowController
{
    windowController = nil;
}

- (void)setWindowControllerData
{
	return;
}

- frameAutosaveName
{
	return [[self className] stringByAppendingString:[self displayName]];
}

- (void)makeWindowControllers
{
	[self initWindowController];
	[[windowController window] setFrameAutosaveName:[self frameAutosaveName]];
	[[windowController window] setFrameUsingName:[self frameAutosaveName]];
    [self addWindowController:windowController];
    [windowController showWindow:self];
	[self setWindowControllerData];
	[windowController prepare];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXDocumentOpenedNotificationName
														object:self];
}

- (PXCanvas *)canvas
{
	return nil;
}

- (void)close
{
#warning The palette flips out sometimes after having gotten this notification... perhaps the canvas is being freed too early?
	if ([[[self canvas] layers] count])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:PXDocumentWillCloseNotificationName
															object:self];
	}
	[super close];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXDocumentDidCloseNotificationName
														object:self];
}

- (void)setFileName:(NSString *)fileName
{
	[super setFileName:fileName];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXDocumentChangedDisplayNameNotificationName object:self];
}

- (PXCanvasWindowController *)windowController;
{
	return windowController;
}
@end
