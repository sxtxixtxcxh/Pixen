//
//  PXPaletteSelector.m
//  Pixen
//
//  Created by Andy Matuschak on 7/8/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXPaletteSelector.h"
#import "PXCanvasDocument.h"
#import "PXCanvas.h"

@implementation PXPaletteSelector

- (id)init
{
	self = [super init];
	_palettes = [[NSMutableArray alloc] init];
	return self;
}

- (void)dealloc
{
	[_palettes release];
	[super dealloc];
}

- (void)setEnabled:(BOOL)enabled
{
	[selectionPopup setEnabled:enabled];
}

- (void)showPalette:(PXPalette *)pal
{
	for (id current in [[selectionPopup menu] itemArray])
	{
		if ([[current representedObject] isEqual:pal])
		{
			[selectionPopup selectItem:current];
			return;
		}
	}
}

- (PXPalette *)reloadDataExcluding:(PXCanvasDocument *)aDoc withCurrentPalette:(PXPalette *)currentPalette
{
	[selectionPopup removeAllItems];
	
	NSUInteger index = [_palettes indexOfObject:currentPalette];
	
	if (index == NSNotFound)
		index = 0;
	
	[_palettes removeAllObjects];
	
	NSArray *userPalettes = [PXPalette userPalettes];
	NSArray *systemPalettes = [PXPalette systemPalettes];
	
	[_palettes addObjectsFromArray:userPalettes];
	[_palettes addObjectsFromArray:systemPalettes];
	
	[selectionPopup setEnabled:YES];
	
	if (![_palettes count])
	{
		[selectionPopup addItemWithTitle:NSLocalizedString(@"No Palettes", @"No Palettes")];
		[selectionPopup setEnabled:NO];
	}
	
	if (index >= [_palettes count])
		index = [_palettes count] - 1;
	
	for (PXPalette *palette in userPalettes)
	{
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:palette.name
													   action:@selector(selectionChanged:)
												keyEquivalent:@""] autorelease];
		[item setRepresentedObject:palette];
		[[selectionPopup menu] addItem:item];
		[item setTarget:self];
	}
	
	if (([userPalettes count] > 0) && ([systemPalettes count] > 0))
	{
		[[selectionPopup menu] addItem:[NSMenuItem separatorItem]];
	}
	
	for (PXPalette *palette in systemPalettes)
	{
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:palette.name
													   action:@selector(selectionChanged:)
												keyEquivalent:@""] autorelease];
		[item setRepresentedObject:palette];
		[[selectionPopup menu] addItem:item];
		[item setTarget:self];
	}
	//FIXME: this should do something about showing the document's palette
	if (([systemPalettes count]) == 0)
	{
		return NULL;
	}
	else
	{
		return [_palettes objectAtIndex:index];
	}
}

- (IBAction)selectionChanged:sender
{
	for (PXPalette *palette in _palettes) {
		if ([palette isEqual:[sender representedObject]]) {
			if ([delegate respondsToSelector:@selector(paletteSelector:selectionDidChangeTo:)])
				[delegate paletteSelector:self selectionDidChangeTo:palette];
			
			return;
		}
	}
}

- (NSArray *)palettes
{
	return _palettes;
}

@end
