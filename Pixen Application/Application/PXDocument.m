//
//  PXDocument.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXDocument.h"

#import "PathUtilities.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvasPrintView.h"
#import "PXCanvasWindowController.h"

@implementation PXDocument

@synthesize windowController = _windowController;

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

- (NSString *)lastSavedFileTypeKey
{
	return nil;
}

- (NSString *)defaultFileType
{
	return nil;
}

- (NSPopUpButton *)popUpButtonInSavePanel:(NSSavePanel *)panel
{
	NSView *accessoryView = [panel accessoryView];
	NSPopUpButton *popUpButton = nil;
	
	if ([[accessoryView subviews] count]) {
		NSView *box = [[accessoryView subviews] objectAtIndex:0];
		
		if ([[box subviews] count]) {
			for (NSView *view in [box subviews]) {
				if ([view isKindOfClass:[NSPopUpButton class]]) {
					popUpButton = (NSPopUpButton *) view;
					break;
				}
			}
		}
	}
	
	return popUpButton;
}

- (BOOL)prepareSavePanel:(NSSavePanel *)savePanel
{
	NSString *lastType = [[NSUserDefaults standardUserDefaults] stringForKey:[self lastSavedFileTypeKey]];
	
	if (!lastType)
		lastType = [self defaultFileType];
	
	NSPopUpButton *popUpButton = [self popUpButtonInSavePanel:savePanel];
	
	if (!popUpButton)
		return NO;
	
	NSString *description = GetDescriptionForDocumentType(lastType);
	[popUpButton selectItemWithTitle:description];
	
	[popUpButton sendAction:[popUpButton action] to:[popUpButton target]];
	
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:lastType]];
	
	return YES;
}

- (void)printDocumentWithSettings:(NSDictionary *)printSettings
				   showPrintPanel:(BOOL)showPanels delegate:(id)delegate
				 didPrintSelector:(SEL)didPrintSelector contextInfo:(void *)contextInfo
{
	if (!_printableView) {
		_printableView = [PXCanvasPrintView viewForCanvas:[self canvas]];
	}
	
	float scale = [[[[self printInfo] dictionary] objectForKey:NSPrintScalingFactor] floatValue];
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform scaleXBy:scale yBy:scale];
	
	[_printableView setBoundsOrigin:[transform transformPoint:[_printableView frame].origin]];
	[_printableView setBoundsSize:[transform transformSize:[_printableView frame].size]];
	
	NSPrintOperation *op = [NSPrintOperation printOperationWithView:_printableView
														  printInfo:[self printInfo]];
	[op setShowsPrintPanel:showPanels];
	[op setShowsProgressPanel:showPanels];
	
	[self runModalPrintOperation:op delegate:nil didRunSelector:NULL contextInfo:NULL];
}

@end
