//
//  PXPaletteSelector.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXPaletteSelector.h"

#import "PXCanvas.h"
#import "PXCanvasDocument.h"

@implementation PXPaletteSelector

@dynamic enabled;
@synthesize selectionPopup = _selectionPopup, delegate = _delegate;

- (id)init
{
	self = [super init];
	if (self) {
		_palettes = [[NSMutableArray alloc] init];
	}
	return self;
}

- (BOOL)isEnabled
{
	return [_selectionPopup isEnabled];
}

- (void)setEnabled:(BOOL)enabled
{
	[_selectionPopup setEnabled:enabled];
}

- (void)showPalette:(PXPalette *)palette
{
	for (id currentItem in [[_selectionPopup menu] itemArray])
	{
		if ([[currentItem representedObject] isEqual:palette])
		{
			[_selectionPopup selectItem:currentItem];
			return;
		}
	}
}

- (PXPalette *)reloadDataWithCurrentPalette:(PXPalette *)currentPalette
{
	[_selectionPopup removeAllItems];
	
	NSUInteger index = [_palettes indexOfObject:currentPalette];
	
	if (index == NSNotFound)
		index = 0;
	
	[_palettes removeAllObjects];
	
	NSArray *userPalettes = [PXPalette userPalettes];
	NSArray *systemPalettes = [PXPalette systemPalettes];
	
	[_palettes addObjectsFromArray:userPalettes];
	[_palettes addObjectsFromArray:systemPalettes];
	
	[_selectionPopup setEnabled:YES];
	
	if (![_palettes count])
	{
		[_selectionPopup addItemWithTitle:NSLocalizedString(@"No Palettes", @"No Palettes")];
		[_selectionPopup setEnabled:NO];
	}
	
	if (index >= [_palettes count])
		index = [_palettes count] - 1;
	
	for (PXPalette *palette in userPalettes)
	{
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:palette.name
													  action:@selector(selectionChanged:)
											   keyEquivalent:@""];
		[item setTarget:self];
		[item setRepresentedObject:palette];
		
		[[_selectionPopup menu] addItem:item];
	}
	
	if (([userPalettes count] > 0) && ([systemPalettes count] > 0))
	{
		[[_selectionPopup menu] addItem:[NSMenuItem separatorItem]];
	}
	
	for (PXPalette *palette in systemPalettes)
	{
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:palette.name
													  action:@selector(selectionChanged:)
											   keyEquivalent:@""];
		[item setTarget:self];
		[item setRepresentedObject:palette];
		
		[[_selectionPopup menu] addItem:item];
	}
	
	//FIXME: this should do something about showing the document's palette
	
	if (([systemPalettes count]) == 0)
	{
		return nil;
	}
	
	return [_palettes objectAtIndex:index];
}

- (IBAction)selectionChanged:(id)sender
{
	for (PXPalette *palette in _palettes)
	{
		if ([palette isEqual:[sender representedObject]])
		{
			if ([_delegate respondsToSelector:@selector(paletteSelector:selectionDidChangeTo:)])
				[_delegate paletteSelector:self selectionDidChangeTo:palette];
			
			return;
		}
	}
}

- (NSArray *)palettes
{
	return _palettes;
}

@end
