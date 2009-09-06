//
//  PXPaletteController.m
//  Pixen
//
//  Created by Joe Osborn on 2007.12.12.
//  Copyright 2007 Open Sword Group. All rights reserved.
//

#import "PXPaletteController.h"

#import "PXPalettePanelPaletteView.h"
#import "PXToolSwitcher.h"
#import "PXToolPaletteController.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXPalette.h"
#import "PXDocument.h"

@implementation PXPaletteController

- init
{
	[super init];
	[NSBundle loadNibNamed:@"PXPaletteController" owner:self];
	return self;
}

- (void)dealloc
{
	PXPalette_release(frequencyPalette);
	[super dealloc];
}

- view
{
	return view;
}

- (void)setDocument:(PXDocument *)doc
{
	[paletteView setDocument:doc];
	canvas = [doc canvas];
}

- (void)updateFrequencies
{
	PXPalette *oldPalette = frequencyPalette;
	frequencyPalette = [canvas createFrequencyPalette];
	[paletteView setPalette:frequencyPalette];
	PXPalette_release(oldPalette);
}

- (void)useColorAtIndex:(unsigned)index event:(NSEvent *)e;
{
	PXToolSwitcher *switcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
	if([e buttonNumber] == 1 || ([e modifierFlags] & NSControlKeyMask))
	{
		switcher = [[PXToolPaletteController sharedToolPaletteController] rightSwitcher];
	}
	[switcher setColor:PXPalette_colorAtIndex(frequencyPalette, index)];	
}

- (void)modifyColorAtIndex:(unsigned)index;
{
#warning put palette adds here
}

- (void)paletteViewSizeChangedTo:(NSControlSize)size
{
	[[NSUserDefaults standardUserDefaults] setInteger:size forKey:PXColorPickerPaletteViewSizeKey];
}

- (BOOL)isPaletteIndexKey:(NSEvent *)event
{
	NSString *chars = [event characters];
	BOOL numpad = [event modifierFlags] & NSNumericPadKeyMask;
	return (([chars intValue] != 0) || ([chars characterAtIndex:0] == '0')) && !numpad;
}

- (void)keyDown:(NSEvent *)event
{
	NSString *chars = [event characters];
	unsigned index = [chars intValue];
	[self useColorAtIndex:index event:event];
}

- (IBAction)useMostRecentColors:sender;
{
	
}

- (IBAction)useMostFrequentColors:sender;
{
	
}

- (IBAction)useColorListColors:sender;
{
	
}

@end

