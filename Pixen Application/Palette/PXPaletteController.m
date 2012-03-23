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

@interface PXPaletteController ()

- (void)refreshPalette:(NSNotification *)note;
- (void)updatePalette:(NSNotification *)note;

@end


@implementation PXPaletteController

#define RECENT_LIMIT 32

@synthesize document = _document, paletteView = _paletteView, progressIndicator = _progressIndicator;

- (id)init
{
	self = [super initWithNibName:@"PXPaletteController" bundle:nil];
	
	_frequencyQueue = dispatch_queue_create("com.Pixen.queue.FrequencyPalette", 0);
	
	_frequencyPalette = [[PXPalette alloc] initWithoutBackgroundColor];
	_recentPalette = [[PXPalette alloc] initWithoutBackgroundColor];
	_mode = PXPaletteModeFrequency;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(refreshPalette:)
												 name:@"PXCanvasFrequencyPaletteRefresh"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updatePalette:)
												 name:@"PXCanvasPaletteUpdate"
											   object:nil];
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_frequencyPalette release];
	[_recentPalette release];
	dispatch_release(_frequencyQueue);
	[super dealloc];
}

- (void)awakeFromNib
{
	_paletteView.allowsColorSelection = NO;
	_paletteView.allowsColorModification = YES;
	_paletteView.delegate = self;
	
	NSResponder *nextResponder = [_paletteView nextResponder];
	[_paletteView setNextResponder:self];
	[self setNextResponder:nextResponder];
}

- (void)setDocument:(PXDocument *)document
{
	if (_document != document)
	{
		_document = document;
		
		[self refreshPalette:nil];
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

- (void)refreshPalette:(NSNotification *)note
{
	PXCanvas *canvas = [note object];
	
	if (![_document containsCanvas:canvas])
		return;
	
	[_progressIndicator startAnimation:nil];
	
	NSArray *layers = [[[canvas layers] copy] autorelease];
	
	dispatch_async(_frequencyQueue, ^{
		
		PXPalette *palette = [PXCanvas frequencyPaletteForLayers:layers];
		
		[_frequencyPalette release];
		_frequencyPalette = [palette retain];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			if (_mode == PXPaletteModeFrequency) {
				[_paletteView setPalette:_frequencyPalette];
			}
			
			[_progressIndicator stopAnimation:nil];
			
		});
		
	});
}

- (void)updatePalette:(NSNotification *)note
{
	if (![_document containsCanvas:[note object]])
		return;
	
	NSDictionary *changes = [note userInfo];
	
	NSCountedSet *oldC = [[[changes objectForKey:@"PXCanvasPaletteUpdateRemoved"] copy] autorelease];
	NSCountedSet *newC = [[[changes objectForKey:@"PXCanvasPaletteUpdateAdded"] copy] autorelease];
	
	dispatch_async(_frequencyQueue, ^{
		
		for (NSColor *old in oldC)
		{
			[_frequencyPalette decrementCountForColor:PXColorFromNSColor(old) byAmount:[oldC countForObject:old]];
		}
		
		//can do 'recent palette' stuff here too. most draws will consist of one new and many old, so just consider the last 100 new?
		
		for (NSColor *new in newC)
		{
			[_frequencyPalette incrementCountForColor:PXColorFromNSColor(new) byAmount:[newC countForObject:new]];
			
#warning TODO: reimplement recents
			//[self addRecentColor:pxColor];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[_paletteView reload];
			
		});
		
	});
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
	
	[switcher setColor:PXColorToNSColor([_frequencyPalette colorAtIndex:index])];
}

- (void)paletteViewSizeChangedTo:(NSControlSize)size
{
	[[NSUserDefaults standardUserDefaults] setInteger:size
											   forKey:PXColorPickerPaletteViewSizeKey];
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
	
	PXCanvas *canvas = [_document canvas];
	
	PXColor srcColor = [_frequencyPalette colorAtIndex:index];
	PXColor destColor = PXColorFromNSColor([[sender color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]);
	
	[canvas replaceColor:srcColor withColor:destColor];
	
	_paletteView.selectionIndex = NSNotFound;
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
	
	_paletteView.selectionIndex = index;
}

- (void)closedColorPanel:(NSNotification *)notification
{
	_paletteView.selectionIndex = NSNotFound;
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
