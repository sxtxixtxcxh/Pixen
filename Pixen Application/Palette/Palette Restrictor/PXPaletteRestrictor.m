#import "PXPaletteRestrictor.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXCanvas_Modifying.h"
#import "PXPaletteSelector.h"

@implementation PXPaletteRestrictor

- init
{
	[self initWithWindowNibName:@"PXPaletteRestrictor"];
	transparency = YES;
	mergeLayers = NO;
	matteImage = YES;
	matteColor = [[NSColor whiteColor] retain];
	return self;
}

- (void)dealloc
{
	[matteColor release];
	[super dealloc];
}

- (IBAction)cancelPressed:(id)sender
{
	[[self window] orderOut:nil];
	[NSApp endSheet:[self window] returnCode:NSCancelButton];
}

- (IBAction)restrictPressed:(id)sender
{
	[[self window] orderOut:nil];
	[NSApp endSheet:[self window] returnCode:NSOKButton];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)info
{
	if(returnCode != NSOKButton) { return; }
	int i;
	for(i = [numberOfColors intValue]; i < palette->colorCount; i++)
	{
		NSColor *current = PXPalette_colorAtIndex(palette, i);
		NSColor *selectedColor = [[[NSColorPanel sharedColorPanel] color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		if([selectedColor isEqual:current])
		{
			[[NSColorPanel sharedColorPanel] setColor:PXPalette_colorAtIndex(palette, [numberOfColors intValue] - 1)];
			break;
		}
	}
	
	[palette->undoManager beginUndoGrouping];
	int index = PXPalette_indexOfColor(palette,[[[NSColorPanel sharedColorPanel] color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]);
	PXPalette_removeAlphaComponents(palette);
	if(index != -1) { [[NSColorPanel sharedColorPanel] setColor:PXPalette_colorAtIndex(palette, index)]; }
	
	
	if (mergeLayers)
	{
		id enumerator = [[canvas layers] objectEnumerator], current;
		NSImage *mergedImage = [canvas exportImage];
		PXLayer *newLayer = [PXLayer layerWithName:@"Merged Layer" image:mergedImage size:[canvas size] palette:[canvas palette]];
		[canvas addLayer:newLayer];
		while (current = [enumerator nextObject])
		{
			[canvas removeLayer:current suppressingNotification:YES];
		}
	}
	
	if (palette != chosenPalette)
	{
		chosenPalette = PXPalette_copy(chosenPalette);
		//chosenPalette->undoManager = [canvas undoManager];
		PXPalette_addColorWithoutDuplicating(chosenPalette, [NSColor clearColor]);
		[canvas setPalette:chosenPalette recache:NO];
		id enumerator = [[canvas layers] objectEnumerator], current;
		while (current = [enumerator nextObject])
		{
			[current adaptToPaletteWithTransparency:transparency matteColor:(matteImage ? [matteColor color] : [NSColor whiteColor])];
		}
	}
	
	/*[palette->undoManager beginUndoGrouping]; {
		[canvas removeColorIndicesAfter:[[self numberOfColors] intValue] - 1];
		while(palette->colorCount < [numberOfColors intValue])
		{
			PXPalette_addColor(palette, [NSColor clearColor]);
		}
		while(palette->colorCount > [numberOfColors intValue])
		{
			PXPalette_removeColorAtIndex(palette, palette->colorCount - 1);
		}
	} [palette->undoManager endUndoGrouping];*/
	[canvas reduceColorsTo:[[self numberOfColors] intValue] withTransparency:transparency matteColor:(matteImage ? [matteColor color] : [NSColor whiteColor])];
	while([canvas palette]->colorCount < [numberOfColors intValue])
	{
		PXPalette_addColor([canvas palette], [NSColor whiteColor]);
	}
	PXPalette_lock([canvas palette]);
	[[canvas palette]->undoManager setActionName:NSLocalizedString(@"Toggle Palette Mode", @"Toggle Palette Mode")];
	[[canvas palette]->undoManager endUndoGrouping];
	[self close];
}

- (void)runRestrictionSheetForPalette:(PXPalette *)pal canvas:(PXCanvas *)canv inWindow:(NSWindow *)wind
{
	chosenPalette = palette = pal;
	canvas = canv;
	[self setNumberOfColors:[NSNumber numberWithInt:MIN(palette->colorCount, 256)]];
	hostWindow = wind;
	[self window];
	[paletteSelector reloadDataExcluding:nil withCurrentPalette:palette];
	[paletteSelector showPalette:palette];
	[NSApp beginSheet:[self window] modalForWindow:hostWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)paletteSelector:(PXPaletteSelector *)selector selectionDidChangeTo:(PXPalette *)aPalette
{
	chosenPalette = aPalette;
	[self setNumberOfColors:[NSNumber numberWithInt:MIN(aPalette->colorCount, 256)]];
}

- (void)setMergeLayers:(BOOL)merge
{
	mergeLayers = merge;
	if (!merge)
	{
		[self willChangeValueForKey:@"transparency"];
		transparency = YES;
		[self didChangeValueForKey:@"transparency"];
	}
}

- numberOfColors
{
	return numberOfColors;
}

- (void)setNumberOfColors:newNumber
{
	[newNumber retain];
	[numberOfColors release];
	numberOfColors = newNumber;
}

@end
