//
//  PXPaletteImporter.m
//  Pixen
//
//  Created by Andy Matuschak on 8/22/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXPaletteImporter.h"
#import "OSPALReader.h"
#import "OSJASCPALReader.h"
#import "OSACTReader.h"
#import "PathUtilities.h"
#import "PXPalette.h"

@implementation PXPaletteImporter

- (void)importPaletteAtPath:(NSString *)path
{
	id reader = nil;
	
	if ([[path pathExtension] isEqualToString:MicrosoftPaletteSuffix])
	{
		NSData *data = [NSData dataWithContentsOfFile:path];
		
		if (!data)
		{
			[NSException raise:@"OSFileError" format:@"Couldn't open %@ for reading", path];
			return;
		}
		
		// We have to determine now if it's a JASC palette or a Microsoft palette. JASC palettes start with "JASC-PAL", so we check against that.
		const unsigned char *bytes = [data bytes];
		
		if (bytes[0] == 'J' && bytes[1] == 'A' && bytes[2] == 'S' && bytes[3] == 'C' && bytes[4] == '-' && bytes[5] == 'P' && bytes[6] == 'A' && bytes[7] == 'L')
			reader = [OSJASCPALReader sharedJASCPALReader];
		else
			reader = [OSPALReader sharedPALReader];
	}
	else if ([[path pathExtension] isEqualToString:AdobePaletteSuffix])
	{
		reader = [OSACTReader sharedACTReader];
	}
	
	NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
	NSString *base = [NSString stringWithString:name];
	int i = 2;
	
	// First make the name not conflict with system palettes
	NSUInteger systemPaletteCount = PXPalette_getSystemPalettes(NULL, 0);
	PXPalette **systemPalettes = malloc(sizeof(PXPalette *) * systemPaletteCount);
	PXPalette_getSystemPalettes(systemPalettes, 0);
	
	NSMutableArray *names = [NSMutableArray array];
	
	for (NSUInteger n = 0; n < systemPaletteCount; n++)
	{
		[names addObject:PXPalette_name(systemPalettes[n])];
	}
	
	free(systemPalettes);
	
	while ([names containsObject:name])
	{
		name = [base stringByAppendingFormat:@" %d", i];
		i++;
	}
	
	// Then user palettes.
	while ([[NSFileManager defaultManager] fileExistsAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:name] stringByAppendingPathExtension:PXPaletteSuffix]])
	{
		name = [base stringByAppendingFormat:@" %d", i];
		i++;
	}
	
	NSString *finalPath = [[GetPixenPaletteDirectory() stringByAppendingPathComponent:name] stringByAppendingPathExtension:PXPaletteSuffix];
	PXPalette *newPal = NULL;
	
	if (reader) // If we've got a reader, we've got to import the format first.
	{
		newPal = [reader paletteWithData:[NSData dataWithContentsOfFile:path]];
	}
	else // It must be a pxpalette.
	{
		newPal = PXPalette_initWithDictionary(PXPalette_alloc(), [NSKeyedUnarchiver unarchiveObjectWithFile:path]);
	}
	
	PXPalette_setName(newPal, name);
	newPal->isSystemPalette = NO;
	newPal->canSave = YES;
	
	[NSKeyedArchiver archiveRootObject:PXPalette_dictForArchiving(newPal) toFile:finalPath];
	PXPalette_release(newPal);
}

- (void)panelDidEndWithReturnCode:(NSInteger)code modalSheet:(BOOL)modalSheet
{
	if (code == NSFileHandlingPanelCancelButton) {
		if (modalSheet) [NSApp stopModal];
		return;
	}
	
	for (NSURL *current in [openPanel URLs]) {
		[self importPaletteAtPath:[current path]];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName
														object:self];
	
	if (modalSheet) [NSApp stopModal];
}

- (void)dealloc
{
	[openPanel release];
	[super dealloc];
}

- (void)runInWindow:(NSWindow *)window
{
	openPanel = [[NSOpenPanel openPanel] retain];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setPrompt:@"Install"];
	[openPanel setTitle:@"Install"];
	[openPanel setAllowedFileTypes:[NSArray arrayWithObjects:PXPaletteSuffix, MicrosoftPaletteSuffix, AdobePaletteSuffix, nil]];
	
	if (window) {
		[openPanel beginSheetModalForWindow:window
						  completionHandler:^(NSInteger result) {
							  [self panelDidEndWithReturnCode:result modalSheet:YES];
						  }];
		
		[NSApp runModalForWindow:openPanel];
	}
	else {
		NSInteger result = [openPanel runModal];
		[self panelDidEndWithReturnCode:result modalSheet:NO];
	}
}

@end
