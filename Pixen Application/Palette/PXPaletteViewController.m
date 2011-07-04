//
//  PXPaletteViewController.m
//  Pixen
//
//  Created by Matt Rajca on 7/2/11.
//  Copyright 2011 Matt Rajca. All rights reserved.
//

#import "PXPaletteViewController.h"

#import "PathUtilities.h"
#import "PXCanvas.h"
#import "PXNamePrompter.h"
#import "PXPaletteExporter.h"
#import "PXPaletteImporter.h"
#import "PXPalettePanel.h"
#import "PXPaletteSelector.h"
#import "PXPaletteView.h"

@interface PXPaletteViewController ()

- (void)reloadDataAndShowCanvas:(PXCanvas *)canvas;
- (void)showPalette:(PXPalette *)palette;

- (void)paletteSelector:(PXPaletteSelector *)selector selectionDidChangeTo:(PXPalette *)palette;

@end


@implementation PXPaletteViewController

@synthesize paletteView, delegate;

- (id)init
{
    self = [super initWithNibName:@"PXPalette" bundle:nil];
    if (self) {
		// [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentAdded:) name:PXDocumentOpenedNotificationName object:nil];
		// [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentClosed:) name:PXDocumentWillCloseNotificationName object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteChanged:) name:PXPaletteChangedNotificationName object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteChanged:) name:PXUserPalettesChangedNotificationName object:nil];
	}
	return self;
}

- (void)dealloc
{
    [namePrompter release];
    [super dealloc];
}

- (void)awakeFromNib
{
	[gearMenu setImage:[NSImage imageNamed:@"actiongear"]];
	[gearMenu setEnabled:YES];
	
	namePrompter = [[PXNamePrompter alloc] init];
	[namePrompter setDelegate:self];
}

/*
- (void)documentAdded:(NSNotification *)notification
{
	[self reloadDataAndShowCanvas:[[notification object] canvas]];
}
 */

- (BOOL)validateMenuItem:(id)item
{
	if ([item action] == @selector(renamePalette:)) {
		return ([paletteView palette]->canSave);
	}
	else if ([item action] == @selector(deletePalette:)) {
		return ([paletteView palette]->canSave);
	}
	
	return YES;
}

- (IBAction)installPalette:sender
{
	id importer = [[PXPaletteImporter alloc] init];
	[importer runInWindow:[[self view] window]];
}

- (IBAction)exportPalette:sender
{
	PXPaletteExporter *exporter = [[PXPaletteExporter alloc] init];
	[exporter runWithPalette:[paletteView palette] inWindow:[[self view] window]];
	[exporter release];
}

- (IBAction)popOut:sender
{
	[PXPalettePanel popWithPalette:[paletteView palette] fromWindow:[[self view] window]];
}

- (void)paletteChanged:(NSNotification *)notification
{
	[self reloadData];
}

- (void)reloadData
{
	PXPalette *palette = [paletteView palette];
	PXPalette *newPalette = [paletteSelector reloadDataExcluding:nil withCurrentPalette:palette];
	
	if (palette == NULL) {
		[self showPalette:newPalette];
		return;
	}
	
	int paletteCount = [paletteSelector paletteCount];
	PXPalette **palettes = [paletteSelector palettes];
	
	int i;
	for (i = 0; i < paletteCount; i++)
	{
		if (palette == palettes[i] || [palette->name isEqualToString:palettes[i]->name])
		{
			[self showPalette:palette];
			return;
		}
	}
	
	[self showPalette:newPalette];
}

- (void)reloadDataAndShow:(PXPalette *)palette
{
	[self reloadData];
	[self showPalette:palette];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	[self reloadData];
}

- (IBAction)duplicatePalette:sender
{
	PXPalette *newPal = PXPalette_copy([paletteView palette]);
	newPal->isSystemPalette = NO;
	newPal->canSave = NO;
	
	NSString *base = [NSString stringWithFormat:@"%@ Copy", newPal->name];
	//FIXME: might not work for other languages
	if ([newPal->name rangeOfString:@" Copy"].location != NSNotFound) {
		base = [newPal->name substringToIndex:NSMaxRange([newPal->name rangeOfString:@" Copy"])];
	}
	
	NSString *name = base;
	
	int i = 2;
	while ([[NSFileManager defaultManager] fileExistsAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:name] stringByAppendingPathExtension:PXPaletteSuffix]])
	{
		name = [base stringByAppendingFormat:@" %d", i];
		i++;
	}
	
	PXPalette_setName(newPal, name);
	newPal->canSave = YES;
	PXPalette_setName(newPal, name);
	
	[self reloadData];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName
														object:self];
	
	[self showPalette:newPal];
	PXPalette_release(newPal);
}

- (IBAction)deletePalette:sender
{
	NSString *name = [paletteView palette]->name;
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[[alert addButtonWithTitle:NSLocalizedString(@"Delete", @"DELETE")] setKeyEquivalent:@""];
	
	NSButton *button = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"CANCEL")];
	[button setKeyEquivalent:@"\r"];
	
	[alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete the palette '%@'?", @"PALETTE_DELETE_PROMPT"), name]];
	[alert setInformativeText:NSLocalizedString(@"This operation cannot be undone.", @"BACKGROUND_DELETE_INFORMATIVE_TEXT")];
	
	[alert beginSheetModalForWindow:[[self view] window]
					  modalDelegate:self
					 didEndSelector:@selector(deleteSheetDidEnd:returnCode:contextInfo:)
						contextInfo:nil];
}

- (void)deleteSheetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn)
	{
		NSString *path = [[GetPixenPaletteDirectory() stringByAppendingPathComponent:[paletteView palette]->name] stringByAppendingPathExtension:PXPaletteSuffix];
		NSError *error = nil;
		
		if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
			[self presentError:error];
			return;
		}
		
		[self reloadData];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName
															object:self];
	}
}

/*
- (void)documentClosed:(NSNotification *)notification
{
	[self reloadDataExcluding:[notification object]];
}
*/

- (void)reloadDataAndShowCanvas:(PXCanvas *)canvas
{
	[self reloadData];
	
	//FIXME: find the palette
	
	/*
	PXPalette *pal = PXPalette_init(PXPalette_alloc());
	[self showPalette:pal];
	 */
}

/*
- (void)documentClosed:(NSNotification *)notification
{
	//FIXME: palette panels need a canvas reference, probably
	id canvas = nil;
	
	if ([notification object] && ([[notification object] canvas] == canvas)) {
		[self close];
		return;
	}
	
	[self reloadData];
}
 */

- (void)showPalette:(PXPalette *)palette
{
	PXPalette *currentPalette = palette;
	
	if ([paletteView palette] != palette) {
		[paletteView setPalette:palette];
	}
	
	if (currentPalette) {
		[paletteSelector showPalette:palette];
	}
	
	[gearMenu setEnabled:YES];
	
	if ([delegate respondsToSelector:@selector(paletteViewControllerDidShowPalette:)]) {
		[delegate paletteViewControllerDidShowPalette:palette];
	}
}

- (IBAction)displayHelp:sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"workingwithpalettes" inBook:@"Pixen Help"];
}

- (IBAction)newPalette:sender
{
	PXPalette *newPal = PXPalette_initWithoutBackgroundColor(PXPalette_alloc());
	newPal->isSystemPalette = NO;
	newPal->canSave = YES;
	
	NSString *base = NSLocalizedString(@"Untitled Palette", @"Untitled Palette");
	NSString *name = base;
	
	int i = 2;
	while ([[NSFileManager defaultManager] fileExistsAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:name] stringByAppendingPathExtension:PXPaletteSuffix]])
	{
		name = [base stringByAppendingFormat:@" %d", i];
		i++;
	}
	
	PXPalette_setName(newPal, name);
	[self reloadDataAndShow:newPal];
	PXPalette_release(newPal);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName
														object:self];
}

- (void)paletteSelector:(PXPaletteSelector *)selector selectionDidChangeTo:(PXPalette *)palette
{
	[self showPalette:palette];
}

- (IBAction)renamePalette:sender
{
	PXPalette *palette = [paletteView palette];
	
	[namePrompter promptInWindow:[[self view] window]
						 context:NULL
					promptString:[NSString stringWithFormat:NSLocalizedString(@"Rename the palette '%@'", @"Rename the palette '%@'"), palette->name]
					defaultEntry:palette->name];
}

- (void)prompter:(id)aPrompter didFinishWithName:(NSString *)aName context:(id)context
{
	int systemPaletteCount = PXPalette_getSystemPalettes(NULL, 0);
	
	PXPalette **systemPalettes = malloc(sizeof(PXPalette *) * systemPaletteCount);
	PXPalette_getSystemPalettes(systemPalettes, 0);
	
	int j;
	for (j = 0; j < systemPaletteCount; j++)
	{
		if ([aName isEqualToString:PXPalette_name(systemPalettes[j])])
		{
			[[NSAlert alertWithMessageText:NSLocalizedString(@"ALREADY_SYSTEM_PALETTE", @"There is already a system palette by that name.")
							 defaultButton:nil
						   alternateButton:nil
							   otherButton:nil
				 informativeTextWithFormat:@""] runModal];
			
			free(systemPalettes);
			
			return;
		}
	}
	
	free(systemPalettes);
	
	PXPalette_setName([paletteView palette], aName);
	[self reloadDataAndShow:[paletteView palette]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName
														object:self];
}

@end
