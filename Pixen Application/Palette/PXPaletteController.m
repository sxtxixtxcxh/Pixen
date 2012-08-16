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
	
	_frequencyQueue = [NSOperationQueue new];
	_recentQueue = [NSOperationQueue new];
	
	[_frequencyQueue setMaxConcurrentOperationCount:1];
	[_recentQueue setMaxConcurrentOperationCount:1];
	
	[_frequencyQueue addObserver:self forKeyPath:@"operationCount" options:0 context:NULL];
	
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

- (void)closedDocument:(NSNotification *)notification
{
	[_frequencyQueue cancelAllOperations];
}

- (void)dealloc
{
	[_frequencyQueue removeObserver:self forKeyPath:@"operationCount"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
	_paletteView.allowsFirstResponder = NO;
	_paletteView.allowsColorSelection = NO;
	_paletteView.allowsColorModification = YES;
	_paletteView.delegate = self;
}

- (void)setDocument:(PXDocument *)document
{
	if (_document != document)
	{
		_document = document;
		
		[self refreshPalette:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(closedDocument:)
													 name:PXDocumentDidCloseNotificationName
												   object:document];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"operationCount"]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([_frequencyQueue operationCount]) {
				[_progressIndicator startAnimation:nil];
			}
			else {
				[_progressIndicator stopAnimation:nil];
			}
		});
	}
}

- (void)refreshPalette:(NSNotification *)note
{
	PXCanvas *canvas = [note object];
	
	if (![_document containsCanvas:canvas])
		return;
	
	[_frequencyQueue cancelAllOperations];
	
	NSArray *layers = [[canvas layers] copy];
	
	NSBlockOperation *op = [[NSBlockOperation alloc] init];
	__weak NSBlockOperation *weakOp = op;
	
	[op addExecutionBlock:^{
		
		PXPalette *palette = [[PXPalette alloc] initWithoutBackgroundColor];
		
		PXLayer *firstLayer = [layers objectAtIndex:0];
		
		CGFloat w = [firstLayer size].width;
		CGFloat h = [firstLayer size].height;
		
		for (PXLayer *current in layers)
		{
			for (CGFloat i = 0; i < w; i++)
			{
				if ([weakOp isCancelled])
					return;
				
				for (CGFloat j = 0; j < h; j++)
				{
					PXColor color = [current colorAtPoint:NSMakePoint(i, j)];
					[palette incrementCountForColor:color byAmount:1];
				}
			}
		}
		
		[palette sortByFrequency];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			_frequencyPalette = palette;
			
			if (_mode == PXPaletteModeFrequency) {
				[_paletteView setPalette:_frequencyPalette];
			}
			
		});
		
	}];
	
	[_frequencyQueue addOperation:op];
}

- (void)updatePalette:(NSNotification *)note
{
	if (![_document containsCanvas:[note object]])
		return;
	
	NSDictionary *changes = [note userInfo];
	
	NSCountedSet *oldC = [[changes objectForKey:@"PXCanvasPaletteUpdateRemoved"] copy];
	NSCountedSet *newC = [[changes objectForKey:@"PXCanvasPaletteUpdateAdded"] copy];
	
	[_frequencyQueue addOperationWithBlock:^{
		
		for (NSColor *old in oldC)
		{
			[_frequencyPalette decrementCountForColor:PXColorFromNSColor(old) byAmount:[oldC countForObject:old]];
		}
		
		//can do 'recent palette' stuff here too. most draws will consist of one new and many old, so just consider the last 100 new?
		
		for (NSColor *new in newC)
		{
			PXColor color = PXColorFromNSColor(new);
			[_frequencyPalette incrementCountForColor:color byAmount:[newC countForObject:new]];
			
			[_recentQueue addOperationWithBlock:^{
				
				[self addRecentColor:color];
				
			}];
		}
		
		[_frequencyPalette sortByFrequency];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[_paletteView reload];
			
		});
		
	}];
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
	
	PXCanvas *canvas = [_document canvas];
	
	PXColor srcColor = [_frequencyPalette colorAtIndex:index];
	PXColor destColor = PXColorFromNSColor([[[sender object] color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]);
	
	[canvas replaceColor:srcColor withColor:destColor];
	
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
