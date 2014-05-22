//
//  PXCanvasWindowController_IBActions.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasWindowController_IBActions.h"

#import "NSImage+Reps.h"
#import "NSWindowController+Additions.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXCanvas_CopyPaste.h"
#import "PXCanvasDocument.h"
#import "PXCanvas_Drawing.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Selection.h"
#import "PXCanvasController.h"
#import "PXCanvasView.h"
#import "PXGridSettingsController.h"
#import "PXInfoView.h"
#import "PXScaleController.h"
#import "PXPaletteExporter.h"
#import "PXPalettePanel.h"
#import "PXLayerController.h"
#import "PXPreviewController.h"
#import "PXTool.h"
#import "PXToolPaletteController.h"
#import "PXToolSwitcher.h"

#import "PXDocumentController.h"
#import "PXAnimationDocument.h"
#import "PXAnimation.h"
#import "PXCel.h"

@implementation PXCanvasWindowController(IBActions)

- (IBAction)createAnimationFromImage:sender
{
	PXDocumentController *docController = [PXDocumentController sharedDocumentController];
	
	NSError *error = nil;
	PXAnimationDocument *doc = [docController makeUntitledDocumentOfType:PixenAnimationFileType
														  showSizePrompt:NO
																   error:&error];
	
	if (!doc) {
		[NSApp presentError:error];
		return;
	}
	
	[docController addDocument:doc];
	
	NSImage *cocoaImage = [NSImage imageWithBitmapImageRep:[[self canvas] imageRep]];
	[[[[doc animation] celAtIndex:0] canvas] replaceActiveLayerWithImage:cocoaImage];
	
	[doc makeWindowControllers];
	[doc showWindows];
	[doc updateChangeCount:NSChangeCleared];
}

- (void)rotateLayerCounterclockwise:sender
{
	[canvas rotateLayer:[canvas activeLayer] byDegrees:90];
}

- (void)rotateLayerClockwise:sender
{
	[canvas rotateLayer:[canvas activeLayer] byDegrees:270];
}

- (void)rotateLayer180:sender
{
	[canvas rotateLayer:[canvas activeLayer] byDegrees:180];
}

- (IBAction)rotateCounterclockwise:sender
{
	[canvas rotateByDegrees:90];
}

- (IBAction)rotateClockwise:sender
{
	[canvas rotateByDegrees:270];
}

- (IBAction)rotate180:sender
{
	[canvas rotateByDegrees:180];
}

- (IBAction)resizeCanvas:(id)sender
{
	NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:PXDefaultNewDocumentBackgroundColor];
	NSColor *backgroundColor = colorData ? [NSKeyedUnarchiver unarchiveObjectWithData:colorData] : [NSColor clearColor];
	
	PXCanvasResizePrompter *prompter = self.resizePrompter;
	prompter.backgroundColor = backgroundColor;
	prompter.oldSize = [canvas size];
	prompter.currentSize = [canvas size];
	
	[prompter promptInWindow:[self window]];
}

- (IBAction)scaleCanvas:(id) sender
{
	[self.scaleController scaleCanvasFromController:self modalForWindow:[self window]];
}

- (IBAction)increaseOpacity:(id)sender
{
	PXToolSwitcher *switcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
	NSColor *color = [switcher color];
	CGFloat a = MIN([color alphaComponent] + 0.1f, 1.0f);
	
	[switcher setColor:[color colorWithAlphaComponent:a]];
}

- (IBAction)decreaseOpacity:(id)sender
{
	PXToolSwitcher *switcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
	NSColor *color = [switcher color];
	CGFloat a = MAX([color alphaComponent] - 0.1f, 0.0f);
	
	[switcher setColor:[color colorWithAlphaComponent:a]];
}

- (IBAction)duplicateDocument:(id)sender
{
	NSError *error = nil;
	
	PXCanvasDocument *newDocument = [[NSDocumentController sharedDocumentController] makeUntitledDocumentOfType:PixenImageFileType
																								 showSizePrompt:NO
																										  error:&error];
	
	if (!newDocument) {
		[NSApp presentError:error];
		return;
	}
	
	[newDocument setCanvas: [canvas copy]];
	
	[[NSDocumentController sharedDocumentController] addDocument:newDocument];
	[newDocument makeWindowControllers];
	[newDocument showWindows];
}

- (IBAction)exportDocumentPalette:(id)sender
{
	PXPaletteExporter *exporter = [[PXPaletteExporter alloc] init];
	
	PXPalette *palette = [PXCanvas frequencyPaletteForLayers:[canvas layers]];
	palette.name = NSLocalizedString(@"Document Palette", nil);
	
	[exporter runWithPalette:palette inWindow:[self window]];
}

- (IBAction)mergeDown:(id) sender
{
	[layerController mergeDownSelectedLayer];
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	if ([anItem action] == @selector(crop:))
		return [[self canvas] hasSelection];
	else if ([anItem action] == @selector(mergeDown:))
		return [[[self canvas] layers] count] > 1 &&
		[[[self canvas] layers] objectAtIndex:0] != [[self canvas] activeLayer];
	else if ([anItem action] == @selector(promoteSelection:))
		return [[self canvas] hasSelection];
	else if ([anItem action] == @selector(deleteLayer:))
		return [[[self canvas] layers] count] > 1;
	else if ([anItem action] == @selector(previousLayer:))
		return [[[self canvas] layers] count] > 1 && [[[self canvas] layers] lastObject] != [[self canvas] activeLayer];
	else if ([anItem action] == @selector(nextLayer:))
		return [[[self canvas] layers] count] > 1 && [[[self canvas] layers] objectAtIndex:0] != [[self canvas] activeLayer];
	else if ([anItem action] == @selector(cut:) || [anItem action] == @selector(copy:) ||
			 [anItem action] == @selector(copyMerged:) || [anItem action] == @selector(selectNone:) ||
			 [anItem action] == @selector(delete:)) {
		return [canvas hasSelection];
	}
	else if ([anItem action] == @selector(paste:) || [anItem action] == @selector(pasteIntoActiveLayer:))
	{
		NSPasteboard *board = [NSPasteboard generalPasteboard];
		
		for (NSString *type in [NSImage imagePasteboardTypes])
		{
			if ([[board types] containsObject:type])
				return YES;
		}
		
		return NO;
	}
	else if ([anItem action] == @selector(cutLayer:))
	{
		return [[canvas layers] count] > 1;
	}
	else if ([anItem action] == @selector(pasteLayer:))
	{
		NSPasteboard *board = [NSPasteboard generalPasteboard];
		return [[board types] containsObject:PXLayerPboardType];
	}
	else if ([anItem action] == @selector(setPatternToSelection:))
		return [[self canvas] hasSelection];
	else if ([anItem action] == @selector(zoomOut:))
	{
		return ([[canvasController view] zoomPercentage] > 100);
	}
	else if ([anItem action] == @selector(zoomIn:))
	{
		return ([[canvasController view] zoomPercentage] < 2000);
	}
	else if ([anItem action] == @selector(increaseOpacity:))
	{
		PXToolSwitcher *switcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
		return ([[switcher color] alphaComponent] < 1.0f);
	}
	else if ([anItem action] == @selector(decreaseOpacity:))
	{
		PXToolSwitcher *switcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
		return ([[switcher color] alphaComponent] > 0.0f);
	}
	else if ([anItem action] == @selector(toggleGrid:))
	{
		if ([[canvas grid] shouldDraw]) {
			[anItem setTitle:@"Hide Grid"];
		}
		else {
			[anItem setTitle:@"Show Grid"];
		}
		
		return YES;
	}
	else if ([anItem action] == @selector(toggleInfo:))
	{
		if ([[NSUserDefaults standardUserDefaults] boolForKey:PXShowInfoKey]) {
			[anItem setTitle:@"Hide Info Bar"];
		}
		else {
			[anItem setTitle:@"Show Info Bar"];
		}
		
		return YES;
	}
	
	return YES;
}

- (void)toggleInfo:(id)sender
{
	BOOL shows = [[NSUserDefaults standardUserDefaults] boolForKey:PXShowInfoKey];
	shows = !shows;
	
	[[NSUserDefaults standardUserDefaults] setBool:shows forKey:PXShowInfoKey];
	
	if (shows) {
		[self.infoView setHidden:NO];
	}
	else {
		[self.infoView setHidden:YES];
	}
}

- (IBAction)promoteSelection:(id) sender
{
	[[canvasController layerController] promoteSelection];
}

- (IBAction)newLayer:(id) sender
{
	[[canvasController layerController] addLayer:sender];
}

- (IBAction)deleteLayer:sender
{
	[layerController removeLayer:nil];
}

- (IBAction)crop:sender
{
	[canvas cropToSelection];
	[canvasController updateCanvasSizeZoomingToFit:NO];		
}

- (IBAction)flipHorizontally:(id)sender
{
	[canvas flipHorizontally];
}

- (IBAction)flipVertically:(id)sender
{
	[canvas flipVertically];
}

- (IBAction)flipLayerHorizontally:(id) sender
{		
	[canvas flipLayerHorizontally:[canvas activeLayer]];
}

- (IBAction)flipLayerVertically:(id) sender
{
	[canvas flipLayerVertically:[canvas activeLayer]];
}

- (IBAction)duplicateLayer:(id) sender
{
	[[canvasController layerController] duplicateSelectedLayer];
}

- (IBAction)toggleVisiblity:(id) sender
{
	[[canvasController layerController] toggleVisibility];
}

- (IBAction)nextLayer:(id) sender
{
	[[canvasController layerController] selectNextLayer];
}

- (IBAction)previousLayer:(id) sender
{
	[[canvasController layerController] selectPreviousLayer];
}

- (IBAction)setPatternToSelection:sender
{
	[canvasController setPatternToSelection];
}

- (IBAction)showPreviewWindow:(id)sender
{
	[[PXPreviewController sharedPreviewController] showWindow:self];
}

- (IBAction)togglePreviewWindow:(id)sender
{
	[[PXPreviewController sharedPreviewController] toggleWindow];
}

- (IBAction)showBackgroundInfo:(id) sender
{
	[canvasController showBackgroundInfo];
}

- (IBAction)toggleGrid:(id)sender
{
	BOOL shouldDraw = [[canvas grid] shouldDraw];
	[[canvas grid] setShouldDraw:!shouldDraw];
	
	[canvas changed];
}

- (IBAction)showGridSettingsPrompter:(id)sender
{
	if (!_gridSettingsController) {
		_gridSettingsController = [[PXGridSettingsController alloc] init];
		_gridSettingsController.delegate = self;
	}
	
	_gridSettingsController.width = (int) [[canvas grid] unitSize].width;
	_gridSettingsController.height = (int) [[canvas grid] unitSize].height;
	_gridSettingsController.color = [[canvas grid] color];
	_gridSettingsController.showGrid = [[canvas grid] shouldDraw];
	
	[_gridSettingsController beginSheetWithParentWindow:[self window]];
}

- (void)gridSettingsController:(PXGridSettingsController *)controller
			   updatedWithSize:(NSSize)size
						 color:(NSColor *)color
					   visible:(BOOL)visible {
	
	PXGrid *grid = [canvas grid];
	[grid setUnitSize:size];
	[grid setColor:color];
	[grid setShouldDraw:visible];
	
	[canvas changed];
}

- (IBAction)redrawCanvas: (id) sender
{
	[canvas changed];
}

- (IBAction)fill:(id)sender
{
	PXToolSwitcher *switcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
	PXColor color = PXColorFromNSColor([switcher color]);
	
	[canvas fillWithColor:color];
}

- (IBAction)cut:sender
{
	[canvas cutSelection];
}

- (IBAction)cutLayer:sender
{
	[[canvasController layerController] cutSelectedLayer];
}

- (IBAction)copyLayer:sender
{
	[[canvasController layerController] copySelectedLayer];
}

- (IBAction)pasteLayer:sender
{
	[[canvasController layerController] pasteLayer];
}

- (IBAction)copy:(id) sender
{
	[canvas copySelection];
}

- (IBAction)copyMerged: (id) sender
{
	[canvas copyMergedSelection];
}

- (IBAction) paste: (id) sender
{
	[canvas paste];
}

- (IBAction) pasteIntoActiveLayer: (id) sender
{
	[canvas pasteIntoLayer:[canvas activeLayer]];
}

- (IBAction)delete:(id) sender
{
	[canvas deleteSelection];
}

- (IBAction)selectAll: (id) sender
{
	[canvas selectAll];
}

- (IBAction)invertSelection: (id) sender
{
	[canvas invertSelection];
}

- (IBAction)selectNone: (id) sender
{
	[canvas deselect];
}

@end
