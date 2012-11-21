//
//  PXPaletteController.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXPaletteController.h"

#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXDocument.h"
#import "PXPalette.h"
#import "PXPaletteView.h"
#import "PXToolPaletteController.h"
#import "PXToolSwitcher.h"

@implementation PXPaletteController

#define RECENT_LIMIT 32

@synthesize canvas = _canvas, paletteView = _paletteView, progressIndicator = _progressIndicator;

- (id)init
{
	self = [super initWithNibName:@"PXPaletteController" bundle:nil];
	
	_recentQueue = [NSOperationQueue new];
	[_recentQueue setMaxConcurrentOperationCount:1];
	
	_recentPalette = [[PXPalette alloc] initWithoutBackgroundColor];
	_mode = PXPaletteModeFrequency;
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
	_paletteView.allowsFirstResponder = NO;
	_paletteView.allowsColorSelection = NO;
	_paletteView.allowsColorModification = YES;
	_paletteView.delegate = self;
}

- (void)setCanvas:(PXCanvas *)canvas
{
	if (_canvas != canvas)
	{
		_canvas = canvas;
		
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(refreshedPalette:)
													 name:PXUpdatedFrequencyPaletteNotificationName
												   object:_canvas];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(toggleProgress:)
													 name:PXToggledFrequencyPaletteUpdationNotificationName
												   object:_canvas];
		
		[_canvas refreshWholePalette];
	}
}

- (void)refreshedPalette:(NSNotification *)note
{
	_frequencyPalette = [note userInfo][@"Palette"];
	
	if (_mode == PXPaletteModeFrequency)
		[_paletteView setPalette:_frequencyPalette];
}

- (void)toggleProgress:(NSNotification *)note
{
	if ([[note userInfo][@"Value"] boolValue]) {
		[_progressIndicator startAnimation:nil];
	}
	else {
		[_progressIndicator stopAnimation:nil];
	}
}

- (void)addRecentColor:(PXColor)color
{
	NSUInteger idx = [_recentPalette indexOfColor:color];
	
	if (idx != NSNotFound)
	{
		if (idx != 0) {
			[_recentPalette removeColorAtIndex:idx];
			[_recentPalette insertColor:color atIndex:0];
		}
	}
	else
	{
		[_recentPalette insertColor:color atIndex:0];
		
		while ([_recentPalette colorCount] > RECENT_LIMIT)
		{
			[_recentPalette removeLastColor];
		}
	}
}

- (void)useColorAtIndex:(NSUInteger)index
{
	PXToolSwitcher *switcher = nil;
	
	//FIXME: decouple this
	if ([NSEvent pressedMouseButtons] == 2 || ([NSEvent modifierFlags] & NSControlKeyMask))
	{
		switcher = [[PXToolPaletteController sharedToolPaletteController] rightSwitcher];
	}
	else
	{
		switcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
	}
	
	PXPalette *palette = _mode == PXPaletteModeFrequency ? _frequencyPalette : _recentPalette;
	
	[switcher setColor:PXColorToNSColor([palette colorAtIndex:index])];
}

- (BOOL)isPaletteIndexKey:(NSEvent *)event
{
	NSString *chars = [event characters];
	
	// not sure why numpad is unacceptable, but whatever
	BOOL numpad = [event modifierFlags] & NSNumericPadKeyMask;
	
	return (([chars integerValue] != 0) || ([chars characterAtIndex:0] == '0')) && !numpad;
}

- (void)keyDown:(NSEvent *)event
{
	NSString *chars = [event characters];
	NSUInteger index = [chars integerValue];
	
	[self useColorAtIndex:index];
}

- (void)changeColor:(id)sender
{
	NSUInteger index = [_paletteView selectionIndex];
	
	if (index == NSNotFound)
		return;
	
	PXColor srcColor = [_frequencyPalette colorAtIndex:index];
	PXColor destColor = PXColorFromNSColor([[[sender object] color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]);
	
	[_canvas replaceColor:srcColor withColor:destColor];
	
	[_paletteView selectColorAtIndex:NSNotFound];
}

- (void)paletteView:(PXPaletteView *)pv modifyColorAtIndex:(NSUInteger)index
{
	NSColor *color = PXColorToNSColor([_frequencyPalette colorAtIndex:index]);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSWindowWillCloseNotification
												  object:nil];
	
	NSColorPanel *colorPanel = [NSColorPanel sharedColorPanel];
	[colorPanel setContinuous:NO];
	[colorPanel setColor:color];
	[colorPanel makeKeyAndOrderFront:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(closedColorPanel:)
												 name:NSWindowWillCloseNotification
											   object:colorPanel];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(changeColor:)
												 name:NSColorPanelColorDidChangeNotification
											   object:colorPanel];
	
	[_paletteView selectColorAtIndex:index];
}

- (void)closedColorPanel:(NSNotification *)notification
{
	[_paletteView selectColorAtIndex:NSNotFound];
}

- (IBAction)useMostRecentColors:(id)sender
{
	_mode = PXPaletteModeRecent;
	
	[_paletteView setAllowsColorModification:NO];
	[_paletteView setPalette:_recentPalette];
}

- (IBAction)useMostFrequentColors:(id)sender
{
	_mode = PXPaletteModeFrequency;
	
	[_paletteView setAllowsColorModification:YES];
	[_paletteView setPalette:_frequencyPalette];
}

@end
