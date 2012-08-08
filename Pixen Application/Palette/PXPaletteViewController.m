//
//  PXPaletteViewController.m
//  Pixen
//
//  Created by Matt Rajca on 7/2/11.
//  Copyright 2011-2012 Matt Rajca. All rights reserved.
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
#import "PXPanelManager.h"

@interface PXPaletteViewController ()

- (void)reloadDataAndShowCanvas:(PXCanvas *)canvas;
- (void)showPalette:(PXPalette *)palette;

@end


@implementation PXPaletteViewController

#define HA 120
#define HD 121
#define SA 122
#define SD 123
#define BA 124
#define BD 125

void RGBtoHSV(PXColor c, CGFloat *h, CGFloat *s, CGFloat *v);

@synthesize paletteSelector, addColorButton, removeColorButton, infoField, paletteView, delegate;

- (id)init
{
    self = [super initWithNibName:@"PXPalette" bundle:nil];
    if (self) {
		_colorControlSize = -1;
		
		// [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentAdded:) name:PXDocumentOpenedNotificationName object:nil];
		// [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentClosed:) name:PXDocumentWillCloseNotificationName object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paletteChanged:) name:PXUserPalettesChangedNotificationName object:nil];
	}
	return self;
}

- (void)dealloc
{
	[paletteView removeObserver:self forKeyPath:@"selectionIndex"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
	[infoField setAlphaValue:0.0f];
	
	namePrompter = [[PXNamePrompter alloc] init];
	[namePrompter setDelegate:self];
	
	[self.paletteView addObserver:self
					   forKeyPath:@"selectionIndex"
						  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
						  context:NULL];
}

/*
- (void)documentAdded:(NSNotification *)notification
{
	[self reloadDataAndShowCanvas:[[notification object] canvas]];
}
 */

- (IBAction)changedControlSize:(id)sender
{
	NSControlSize size = [sender selectedSegment] == 1 ? NSSmallControlSize : NSRegularControlSize;
	[[NSUserDefaults standardUserDefaults] setInteger:size forKey:PXColorPickerPaletteViewSizeKey];
	
	[self setColorControlSize:size];
}

- (void)setColorControlSize:(NSControlSize)colorControlSize
{
	if (_colorControlSize != colorControlSize) {
		_colorControlSize = colorControlSize;
		
		[paletteView setControlSize:colorControlSize];
		
		if (colorControlSize == NSSmallControlSize) {
			[self.controlSize selectSegmentWithTag:1];
		}
		else {
			[self.controlSize selectSegmentWithTag:0];
		}
	}
}

- (BOOL)validateMenuItem:(id)item
{
	if ([item tag] >= HA) {
		return [paletteView palette].canSave;
	}
	
	if ([item action] == @selector(renamePalette:)) {
		return ([paletteView palette].canSave);
	}
	else if ([item action] == @selector(deletePalette:)) {
		return ([paletteView palette].canSave);
	}
	
	return YES;
}

void RGBtoHSV(PXColor c, CGFloat *h, CGFloat *s, CGFloat *v)
{
	CGFloat r = c.r / 255.0f;
	CGFloat g = c.g / 255.0f;
	CGFloat b = c.b / 255.0f;
	
	CGFloat min, max, delta;
	min = MIN(MIN(r, g), b);
	max = MAX(MAX(r, g), b);
	
	*v = max;
	
	delta = max - min;
	
	if (max != 0)
		*s = delta / max;
	else {
		*s = 0;
		*h = -1;
		return;
	}
	
	if (r == max)
		*h = (g - b) / delta;
	else if (g == max)
		*h = 2 + (b - r) / delta;
	else
		*h = 4 + (r - g) / delta;
	
	*h *= 60;
	
	if (*h < 0)
		*h += 360;
}

- (IBAction)sortByColor:(id)sender
{
	[[paletteView palette] sortWithBlock:^int(PXColor *a, PXColor *b) {
		
		CGFloat hsv1[3];
		CGFloat hsv2[3];
		
		RGBtoHSV(*a, hsv1, hsv1+1, hsv1+2);
		RGBtoHSV(*b, hsv2, hsv2+1, hsv2+2);
		
		if ([sender tag] == HA) {
			if (hsv1[0] == hsv2[0]) return 0;
			else if (hsv1[0] < hsv2[0]) return -1;
			else return 1;
		}
		else if ([sender tag] == HD) {
			if (hsv1[0] == hsv2[0]) return 0;
			else if (hsv1[0] < hsv2[0]) return 1;
			else return -1;
		}
		else if ([sender tag] == SA) {
			if (hsv1[1] == hsv2[1]) return 0;
			else if (hsv1[1] < hsv2[1]) return -1;
			else return 1;
		}
		else if ([sender tag] == SD) {
			if (hsv1[1] == hsv2[1]) return 0;
			else if (hsv1[1] < hsv2[1]) return 1;
			else return -1;
		}
		else if ([sender tag] == BA) {
			if (hsv1[2] == hsv2[2]) return 0;
			else if (hsv1[2] < hsv2[2]) return -1;
			else return 1;
		}
		else if ([sender tag] == BD) {
			if (hsv1[2] == hsv2[2]) return 0;
			else if (hsv1[2] < hsv2[2]) return 1;
			else return -1;
		}
		
		return 0;
		
	}];
	
	[[paletteView palette] save];
	[paletteView reload];
}

- (IBAction)addColor:(id)sender
{
	PXPalette *palette = [paletteView palette];
	
	if (!palette.canSave)
		return;
	
	[palette addColorWithoutDuplicating:PXColorFromNSColor([[[NSColorPanel sharedColorPanel] color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace])];
	[palette save];
	
	[self.paletteView reload];
}

- (IBAction)removeColor:(id)sender
{
	PXPalette *palette = [paletteView palette];
	
	if (!palette.canSave)
		return;
	
	[self.paletteView deleteBackward:nil];
}

- (IBAction)installPalette:sender
{
	PXPaletteImporter *importer = [[PXPaletteImporter alloc] init];
	[importer runInWindow:[[self view] window]];
}

- (IBAction)exportPalette:sender
{
	PXPaletteExporter *exporter = [[PXPaletteExporter alloc] init];
	[exporter runWithPalette:[paletteView palette] inWindow:[[self view] window]];
}

- (IBAction)popOut:sender
{
	PXPalettePanel *panel = [PXPalettePanel popWithPalette:[paletteView palette]
												fromWindow:[[self view] window]];
	
	[[PXPanelManager sharedManager] addPalettePanel:panel];
	
	[panel makeKeyAndOrderFront:self];
}

- (void)paletteChanged:(NSNotification *)notification
{
	[self reloadData];
}

- (void)reloadData
{
	PXPalette *palette = [paletteView palette];
	PXPalette *newPalette = [paletteSelector reloadDataWithCurrentPalette:palette];
	
	if (palette == nil) {
		[self showPalette:newPalette];
		return;
	}
	
	NSArray *palettes = [paletteSelector palettes];
	
	for (PXPalette *currentPalette in palettes) {
		if ([palette isEqual:currentPalette])
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
	PXPalette *newPal = [[paletteView palette] copy];
	newPal.isSystemPalette = NO;
	newPal.canSave = YES;
	
	NSString *base = [NSString stringWithFormat:@"%@ Copy", newPal.name];
	//FIXME: might not work for other languages
	if ([newPal.name rangeOfString:@" Copy"].location != NSNotFound) {
		base = [newPal.name substringToIndex:NSMaxRange([newPal.name rangeOfString:@" Copy"])];
	}
	
	NSString *name = base;
	
	int i = 2;
	while ([[NSFileManager defaultManager] fileExistsAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:name] stringByAppendingPathExtension:PXPaletteSuffix]])
	{
		name = [base stringByAppendingFormat:@" %d", i];
		i++;
	}
	
	newPal.name = name;
	
	[newPal save];
	
	[self reloadData];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName
														object:self];
	
	[self showPalette:newPal];
}

- (IBAction)deletePalette:sender
{
	NSString *name = [paletteView palette].name;
	
	NSAlert *alert = [[NSAlert alloc] init];
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
		[[paletteView palette] removeFile];
		
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

- (void)validateRemoveColorButton
{
	if (!paletteView.palette.canSave) {
		[self.removeColorButton setEnabled:NO];
		return;
	}
	
	[self.removeColorButton setEnabled:paletteView.selectionIndex != NSNotFound];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self validateRemoveColorButton];
}

- (void)showPalette:(PXPalette *)palette
{
	[addColorButton setEnabled:palette.canSave];
	
	if ([paletteView palette] != palette) {
		[paletteView setPalette:palette];
	}
	
	if (palette) {
		[paletteSelector showPalette:palette];
	}
	
	[self validateRemoveColorButton];
	
	if ([delegate respondsToSelector:@selector(paletteViewControllerDidShowPalette:)]) {
		[delegate paletteViewControllerDidShowPalette:palette];
	}
}

- (IBAction)newPalette:sender
{
	PXPalette *newPal = [[PXPalette alloc] initWithoutBackgroundColor];
	newPal.isSystemPalette = NO;
	newPal.canSave = YES;
	
	NSString *base = NSLocalizedString(@"Untitled Palette", @"Untitled Palette");
	NSString *name = base;
	
	int i = 2;
	while ([[NSFileManager defaultManager] fileExistsAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:name] stringByAppendingPathExtension:PXPaletteSuffix]])
	{
		name = [base stringByAppendingFormat:@" %d", i];
		i++;
	}
	
	newPal.name = name;
	
	[newPal save];
	
	[self reloadDataAndShow:newPal];
	
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
					promptString:[NSString stringWithFormat:NSLocalizedString(@"Rename the palette '%@'", @"Rename the palette '%@'"), palette.name]
					defaultEntry:palette.name];
}

- (void)prompter:(id)aPrompter didFinishWithName:(NSString *)aName context:(id)context
{
	NSArray *systemPalettes = [PXPalette systemPalettes];
	
	for (PXPalette *palette in systemPalettes)
	{
		if ([aName isEqualToString:palette.name])
		{
			[[NSAlert alertWithMessageText:NSLocalizedString(@"ALREADY_SYSTEM_PALETTE", @"There is already a system palette by that name.")
							 defaultButton:nil
						   alternateButton:nil
							   otherButton:nil
				 informativeTextWithFormat:@""] runModal];
			
			return;
		}
	}
	
	PXPalette *palette = [paletteView palette];
	[palette removeFile];
	[palette setName:aName];
	[palette save];
	
	[self reloadDataAndShow:palette];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXUserPalettesChangedNotificationName
														object:self];
}

- (void)showColorModificationInfo
{
	[[infoField animator] setAlphaValue:1.0f];
	
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 4.0f * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^{
		
		[[infoField animator] setAlphaValue:0.0f];
		
	});
}

@end
