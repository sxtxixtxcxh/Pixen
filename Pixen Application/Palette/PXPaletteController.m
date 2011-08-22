  //
  //  PXPaletteController.m
  //  Pixen
  //
  //  Created by Joe Osborn on 2007.12.12.
  //  Copyright 2007 Pixen. All rights reserved.
  //

#import "PXPaletteController.h"

#import "PXToolSwitcher.h"
#import "PXToolPaletteController.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXPalette.h"
#import "PXDocument.h"
#import "PXPaletteView.h"

@implementation PXPaletteController

- (id)init
{
	self = [super initWithNibName:@"PXPaletteController" bundle:nil];
	
	frequencyPalette = [[PXPalette alloc] initWithoutBackgroundColor];
	recentLimit = 32;
	recentPalette = [[PXPalette alloc] initWithoutBackgroundColor];
	mode = PXPaletteModeFrequency;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPalette:) name:@"PXCanvasFrequencyPaletteRefresh" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePalette:) name:@"PXCanvasPaletteUpdate" object:nil];
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[frequencyPalette release];
	[recentPalette release];
	[super dealloc];
}

- (void)awakeFromNib
{
	paletteView.highlightEnabled = NO;
}

- (void)setDocument:(PXDocument *)doc
{
	[paletteView setDocument:doc];
	document = doc;
	[self refreshPalette:nil];
}

- (void)refreshPalette:(NSNotification *)note
{
	if(![document containsCanvas:[note object]])
	{
		return;
	}
	
	PXPalette *oldPal = frequencyPalette;
	frequencyPalette = [[note object] newFrequencyPalette];
	[oldPal release];
	if(mode == PXPaletteModeFrequency)
	{
		[paletteView setPalette:frequencyPalette];
	}
}

- (void)addRecentColor:(NSColor *)c
{
	NSUInteger idx = [recentPalette indexOfColor:c];
	
	if (idx != NSNotFound)
	{
		if (idx != 0) {
			[recentPalette removeColorAtIndex:idx];
			[recentPalette insertColor:c atIndex:0];
		}
	}
	else
	{
		[recentPalette insertColor:c atIndex:0];
		
		while ([recentPalette colorCount] > recentLimit)
		{
			[recentPalette removeLastColor];
		}
	}
}

- (void)updatePalette:(NSNotification *)note
{
	if(![document containsCanvas:[note object]])
	{
		return;
	}
	NSDictionary *changes = [note userInfo];
	//for each canvas
	NSCountedSet *oldC = [changes objectForKey:@"PXCanvasPaletteUpdateRemoved"];
	NSCountedSet *newC = [changes objectForKey:@"PXCanvasPaletteUpdateAdded"];
	for(NSColor *old in oldC)
	{
		// NSLog(@"Color %@ was removed %d times", old, [oldC countForObject:old]);
		[frequencyPalette decrementCountForColor:old byAmount:[oldC countForObject:old]];
	}
	//can do 'recent palette' stuff here too. most draws will consist of one new and many old, so just consider the last 100 new?
	for(NSColor *new in newC)
	{
		//NSLog(@"Color %@ was added %d times", new, [newC countForObject:new]);
		[frequencyPalette incrementCountForColor:new byAmount:[newC countForObject:new]];
		[self addRecentColor:new];
	}
	[paletteView setNeedsRetile];
}

- (void)useColorAtIndex:(NSUInteger)index
{
	PXToolSwitcher *switcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
	
	if ([NSEvent pressedMouseButtons] == 2 || ([NSEvent modifierFlags] & NSControlKeyMask))
	{
		switcher = [[PXToolPaletteController sharedToolPaletteController] rightSwitcher];
	}
	
	[switcher setColor:[frequencyPalette colorAtIndex:index]];
}

- (void)paletteViewSizeChangedTo:(NSControlSize)size
{
	[[NSUserDefaults standardUserDefaults] setInteger:size forKey:PXColorPickerPaletteViewSizeKey];
}

- (BOOL)isPaletteIndexKey:(NSEvent *)event
{
	NSString *chars = [event characters];
	//not sure why numpad is unacceptable, but whatever
	BOOL numpad = [event modifierFlags] & NSNumericPadKeyMask;
	return (([chars intValue] != 0) || ([chars characterAtIndex:0] == '0')) && !numpad;
}

- (void)keyDown:(NSEvent *)event
{
	NSString *chars = [event characters];
	unsigned index = [chars intValue];
	[self useColorAtIndex:index];
}

- (IBAction)useMostRecentColors:sender;
{
	mode = PXPaletteModeRecent;
	[paletteView setPalette:recentPalette];
}

- (IBAction)useMostFrequentColors:sender;
{
	mode = PXPaletteModeFrequency;
	[paletteView setPalette:frequencyPalette];
}

- (IBAction)useColorListColors:sender;
{
	mode = PXPaletteModeColorList;
}

@end

