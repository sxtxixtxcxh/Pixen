//
//  PXCanvasWindowController_Toolbar.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasWindowController_Toolbar.h"

#import "PXPanelManager.h"

@implementation PXCanvasWindowController(Toolbar)

NSString *PXBackgroundConfigurator = @"PXBackgroundConfigurator";
NSString *PXPreview = @"PXPreview";
NSString *PXToolProperties = @"PXToolProperties";
NSString *PXGridConfigurator = @"PXGridConfigurator";
NSString *PXZoomFit = @"PXZoomFit";
NSString *PXZoom100 = @"PXZoom100";
NSString *PXScale = @"PXScale";
NSString *PXResize = @"PXResize";
NSString *PXZoom = @"PXZoom";

- (void)prepareToolbar
{
	toolbar = [[NSToolbar alloc] initWithIdentifier:PXCanvasDocumentToolbarIdentifier];
	[toolbar setDelegate:self];
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setAutosavesConfiguration:YES];
	[[self window] setToolbar:toolbar];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar 
	 itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	if ([itemIdentifier isEqualToString:PXBackgroundConfigurator])
	{
		[item setLabel:NSLocalizedString(@"BACKGROUND_LABEL", @"Background Label")];
		[item setToolTip:NSLocalizedString(@"BACKGROUND_TOOLTIP", @"Background Tooltip")];
		[item setAction:@selector(showBackgroundInfo:)];
		[item setImage:[NSImage imageNamed:@"bgconf"]];
	}
	else if ([itemIdentifier isEqualToString:PXPreview])
	{
		[item setLabel:NSLocalizedString(@"PREVIEW_LABEL", @"Preview Label")];
		[item setToolTip:NSLocalizedString(@"PREVIEW_TOOLTIP", @"Preview Tooltip")];
		[item setAction:@selector(togglePreviewWindow:)];
		[item setImage:[NSImage imageNamed:@"preview"]];
	}
	else if ([itemIdentifier isEqualToString:PXToolProperties])
	{
		[item setLabel:NSLocalizedString(@"TOOL_PROPERTIES_LABEL", @"Tool Properties Label")];
		[item setToolTip:NSLocalizedString(@"TOOL_PROPERTIES_TOOLTIP", @"Tool Properties Tooltip")];
		[item setTarget:[PXPanelManager sharedManager]];
		[item setAction:@selector(toggleLeftToolProperties:)];
		[item setImage:[NSImage imageNamed:@"toolproperties"]];
	}
	else if ([itemIdentifier isEqualToString:PXGridConfigurator])
	{
		[item setLabel:NSLocalizedString(@"GRID_LABEL", @"Grid Label")];
		[item setToolTip:NSLocalizedString(@"GRID_TOOLTIP", @"Grid Tooltip")];
		[item setAction:@selector(showGridSettingsPrompter:)];
		[item setImage:[NSImage imageNamed:@"grid"]];
	}
	else if ([itemIdentifier isEqualToString:PXZoomFit])
	{		
		[item setLabel:NSLocalizedString(@"ZOOM_FIT_LABEL", @"Zoom Fit Label")];
		[item setToolTip:NSLocalizedString(@"ZOOM_FIT_TOOLTIP", @"Zoom Fit Tooltip")];
		[item setAction:@selector(zoomToFit:)];
		[item setImage:[NSImage imageNamed:@"zoomfit"]];
	}
	else if ([itemIdentifier isEqualToString:PXZoom100])
	{
		[item setLabel:NSLocalizedString(@"ZOOM_ACTUAL_LABEL", @"Zoom Actual Label")];
		[item setToolTip:NSLocalizedString(@"ZOOM_ACTUAL_TOOLTIP", @"Zoom Actual Tooltip")];
		[item setAction:@selector(zoomStandard:)];
		[item setImage:[NSImage imageNamed:@"zoom100"]];
	}
	else if ([itemIdentifier isEqualToString:PXScale])
	{
		[item setLabel:NSLocalizedString(@"SCALE_LABEL", @"Scale Label")];
		[item setToolTip:NSLocalizedString(@"SCALE_TOOLTIP", @"Scale Tooltip")];
		[item setAction:@selector(scaleCanvas:)];
		[item setImage:[NSImage imageNamed:@"scale"]];
	}
	else if ([itemIdentifier isEqualToString:PXResize])
	{
		[item setLabel:NSLocalizedString(@"RESIZE_LABEL", @"Resize Label")];
		[item setToolTip:NSLocalizedString(@"RESIZE_TOOLTIP", @"Resize Tooltip")];
		[item setAction:@selector(resizeCanvas:)];
		[item setImage:[NSImage imageNamed:@"resize"]];
	}
	else if ([itemIdentifier isEqualToString:PXZoom])
	{
		[item setLabel:NSLocalizedString(@"ZOOM_LABEL", @"Zoom Label")];
		[item setToolTip:NSLocalizedString(@"ZOOM_TOOLTIP", @"Zoom Tooltip")];
		[item setView:zoomView];
		[item setMinSize:NSMakeSize(124,NSHeight([zoomView frame]))];
		[item setMaxSize:NSMakeSize(124,NSHeight([zoomView frame]))];
	}
	[item setPaletteLabel:[item label]];
	if(![item target])
	{
		[item setTarget:self];
	}
	return item;
}

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects:PXBackgroundConfigurator,
			PXPreview, PXZoom, 
			PXZoomFit, PXZoom100,
			PXResize, PXScale,
			PXGridConfigurator,
			NSToolbarCustomizeToolbarItemIdentifier, 
			NSToolbarSpaceItemIdentifier,
			NSToolbarSeparatorItemIdentifier,
			NSToolbarFlexibleSpaceItemIdentifier, 
			nil];
}

- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects:PXBackgroundConfigurator, PXGridConfigurator,
			NSToolbarSeparatorItemIdentifier, PXPreview,
			NSToolbarFlexibleSpaceItemIdentifier, PXZoom, nil];
}

@end
