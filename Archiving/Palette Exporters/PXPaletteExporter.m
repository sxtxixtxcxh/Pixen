//
//  PXPaletteExporter.m
//  Pixen
//
//  Created by Andy Matuschak on 8/21/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXPaletteExporter.h"
#import "OSPALWriter.h"
#import "OSJASCPALWriter.h"
#import "OSACTWriter.h"

@implementation PXPaletteExporter

+ (NSArray *)types
{
	return [NSArray arrayWithObjects:PixenPaletteType, MicrosoftPaletteType, JascPaletteType, AdobePaletteType, nil];
}

- (void)dealloc
{
	[savePanel release];
	[typeSelector release];
	[super dealloc];
}

- (void)panelDidEndWithReturnCode:(NSInteger)code
{
	if (code == NSFileHandlingPanelCancelButton) {
		[NSApp stopModal];
		return;
	}
	
	NSString *type = [[typeSelector selectedItem] title];
	
	if ([type isEqualToString:PixenPaletteType]) {
		[NSKeyedArchiver archiveRootObject:[palette dictForArchiving] toFile:[[savePanel URL] path]];
	}
	else {
		id writer = nil;
		
		if ([type isEqualToString:MicrosoftPaletteType]) {
			writer = [OSPALWriter sharedPALWriter];
		}
		else if ([type isEqualToString:JascPaletteType]) {
			writer = [OSJASCPALWriter sharedJASCPALWriter];
		}
		else if ([type isEqualToString:AdobePaletteType]) {
			writer = [OSACTWriter sharedACTWriter];
		}
		
		if (writer == nil) {
			[NSApp stopModal];
			return;
		}
		
		NSData *data = [writer palDataForPalette:palette];
		
		if (data == nil) {
			[NSApp stopModal];
			return;
		}
		
		[data writeToURL:[savePanel URL] atomically:YES];
	}
	
	[NSApp stopModal];
}

- (NSString *)panel:(id)sender userEnteredFilename:(NSString *)filename confirmed:(BOOL)okFlag
{
	NSString *type = [[typeSelector selectedItem] title];
	
	NSString *basename = [[filename lastPathComponent] stringByDeletingPathExtension];
	NSString *path = nil;
	
	if ([type isEqualToString:PixenPaletteType])
		path = [basename stringByAppendingPathExtension:PXPaletteSuffix];
	else if ([type isEqualToString:MicrosoftPaletteType])
		path = [basename stringByAppendingPathExtension:MicrosoftPaletteSuffix];
	else if ([type isEqualToString:JascPaletteType])
		path = [basename stringByAppendingPathExtension:MicrosoftPaletteSuffix];
	else
		path = [basename stringByAppendingPathExtension:AdobePaletteSuffix];
	
	return path;
}

- (void)runWithPalette:(PXPalette *)aPalette inWindow:(NSWindow *)window
{
	if (aPalette == NULL)
		return;
	
	palette = [aPalette retain];
	
	savePanel = [[NSSavePanel savePanel] retain];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObjects:PXPaletteSuffix, MicrosoftPaletteSuffix, AdobePaletteSuffix, nil]];
	[savePanel setPrompt:@"Export"];
	[savePanel setExtensionHidden:YES];
	[savePanel setNameFieldStringValue:palette.name];
	[savePanel setDelegate:self];
	
	typeSelector = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 250, 40) pullsDown:NO];
	[typeSelector addItemsWithTitles:[[self class] types]];
	[savePanel setAccessoryView:typeSelector];
	
	[savePanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
		[self panelDidEndWithReturnCode:result];
	}];
	
	[NSApp runModalForWindow:savePanel];
	
	[palette release];
}

@end
