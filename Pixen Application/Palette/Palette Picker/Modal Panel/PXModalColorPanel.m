//
//  PXModalColorPanel.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.11.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "PXModalColorPanel.h"
#import "PXColorPicker.h"

@implementation NSColorPanel(Modality)
- (BOOL)isModal
{
	return NO;
}
@end

@interface NSColorPanel(PrivateMethods)
- _colorPickers;
- (void)_magnify:sender;
- _toolTipForColorPicker:picker;
@end

@interface _NSColorPanelToolbar : NSToolbar
{
    NSColorPanel *colorPanel;
    BOOL _isMoving;
    BOOL _refusesToBeShown;
}

+ (void)attachToolbarToColorPanel:(id)fp8;
- (id)initWithIdentifier:(id)fp8 forColorPanel:(id)fp12;
- (void)dealloc;
- (void)setVisible:(BOOL)fp8;
- (void)setRefusesToBeShown:(BOOL)fp8;
- (BOOL)refusesToBeShown;
- (id)itemIdentifierForColorPicker:(id)fp8;
- (void)colorPanelDidSelectColorPicker:(id)fp8;
- (void)setDisplayMode:(int)fp8;
- (void)setSizeMode:(int)fp8;
- (int)sizeMode;
- (int)displayMode;
- (BOOL)_isMoving;
- (id)configurationDictionary;
- (id)_labelForColorPicker:(id)fp8;
- (id)_imageForColorPicker:(id)fp8;
- (id)_tooltipForColorPicker:(id)fp8;
- (id)_itemIdentifiersForColorPickers:(id)fp8;
- (id)_colorPickerWithIdentifier:(id)fp8;
- (id)toolbar:(id)fp8 itemForItemIdentifier:(id)fp12 willBeInsertedIntoToolbar:(BOOL)fp16;
- (id)toolbarDefaultItemIdentifiers:(id)fp8;
- (id)toolbarAllowedItemIdentifiers:(id)fp8;
- (id)toolbarSelectableItemIdentifiers:(id)fp8;
- (void)syncWithRemoteToolbars;

@end

NSString *PXModalColorPanelToolbarIdentifier = @"PXModalColorPanelToolbarIdentifier";

@implementation PXModalColorPanel

- (BOOL)isModal
{
	return YES;
}

#warning Private methods out the yin-yang, so to speak.

+ (PXModalColorPanel *)sharedColorPanel
{
	static PXModalColorPanel *sharedColorPanel = nil;
	if(!sharedColorPanel)
	{
		NSRect frame = [[[NSColorPanel sharedColorPanel] contentView] frame];
		sharedColorPanel = [[self alloc] initWithContentRect:NSMakeRect(0, 0, NSWidth(frame), NSHeight(frame) + 50) styleMask:NSMacintoshInterfaceStyle backing:NSBackingStoreBuffered defer:YES];
	}
	return sharedColorPanel;
}

- (void)performClose:sender
{
	return;
}

- (void)setAlpha:(double)alph
{
	[self setColor:[[self color] colorWithAlphaComponent:alph]];
	[alphaSlider setDoubleValue:alph];
	[alphaField setIntValue:alph * 100];
}

- (void)alphaFieldChanged:sender
{
	[self setAlpha:[sender intValue] / 100.0];
}

- (void)alphaSliderChanged:sender
{
	[self setAlpha:[sender doubleValue]];
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag
{
#warning do this in a nib instead!!!
	[super initWithContentRect:contentRect styleMask:styleMask backing:backingType defer:flag];
	NSRect containerFrame = [[self contentView] frame];
	containerFrame.origin.y += 70;
	containerFrame.size.height -= 102;
	alphaSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(10, 38, NSWidth([[self contentView] frame]) - 65, 24)];
	[alphaSlider setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
	[[alphaSlider cell] setControlSize:NSSmallControlSize];
	[alphaSlider setMinValue:0];
	[alphaSlider setMaxValue:1];
	[alphaSlider setTickMarkPosition:NSTickMarkAbove];
	[alphaSlider setNumberOfTickMarks:3];
	[alphaSlider setTarget:self];
	[alphaSlider setAction:@selector(alphaSliderChanged:)];
	[[self contentView] addSubview:alphaSlider];
	alphaField = [[NSTextField alloc] initWithFrame:NSMakeRect(NSWidth([[self contentView] frame]) - 51, 42, 36, 18)];
	[alphaField setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
	[alphaField setAlignment:NSCenterTextAlignment];
	[[alphaField cell] setControlSize:NSSmallControlSize];
	[[alphaField cell] setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setMinimum:[NSNumber numberWithInt:0]];
	[formatter setMaximum:[NSNumber numberWithInt:100]];
	[formatter setFormat:@"##0"];
	[alphaField setFormatter:formatter];
	[alphaField setTarget:self];
	[alphaField setAction:@selector(alphaFieldChanged:)];
	[[self contentView] addSubview:alphaField];
	percentLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(NSWidth([[self contentView] frame]) - 15, 42, 10, 16)];
	[percentLabel setEditable:NO];
	[percentLabel setBordered:NO];
	[percentLabel setDrawsBackground:NO];
	[percentLabel setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
	[[percentLabel cell] setControlSize:NSSmallControlSize];
	[[percentLabel cell] setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[percentLabel setStringValue:@"%"];
	[[self contentView] addSubview:percentLabel];
	opacityLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 58, NSWidth([[self contentView] frame]) - 60, 16)];
	[opacityLabel setEditable:NO];
	[opacityLabel setBordered:NO];
	[opacityLabel setDrawsBackground:NO];
	[opacityLabel setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin];
	[[opacityLabel cell] setControlSize:NSSmallControlSize];
	[[opacityLabel cell] setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
	[opacityLabel setStringValue:NSLocalizedString(@"Opacity", @"Opacity")];
	[[self contentView] addSubview:opacityLabel];
	cancelButton = [[NSButton alloc] initWithFrame:NSMakeRect(5, 10, 90, 24)];
	[cancelButton setButtonType:NSMomentaryPushInButton];
	[cancelButton setKeyEquivalent:@"."];
	[cancelButton setKeyEquivalentModifierMask:NSCommandKeyMask];
	[cancelButton setImagePosition:NSNoImage];
	[cancelButton setBordered:YES];
	[cancelButton setBezelStyle:NSRoundedBezelStyle];
	[cancelButton setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin];
	[cancelButton setTitle:NSLocalizedString(@"Cancel", @"Cancel")];
	[cancelButton setTarget:self];
	[cancelButton setAction:@selector(cancel:)];
	[[self contentView] addSubview:cancelButton];
	applyButton = [[NSButton alloc] initWithFrame:NSMakeRect(NSWidth([[self contentView] frame]) - 95, 10, 90, 24)];
	[applyButton setKeyEquivalent:@"\r"];
	[applyButton setKeyEquivalentModifierMask:0];
	[applyButton setButtonType:NSMomentaryPushInButton];
	[applyButton setImagePosition:NSNoImage];
	[applyButton setBordered:YES];
	[applyButton setBezelStyle:NSRoundedBezelStyle];
	[applyButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
	[applyButton setTitle:NSLocalizedString(@"Apply", @"Apply")];
	[applyButton setTarget:self];
	[applyButton setAction:@selector(apply:)];
	[[self contentView] addSubview:applyButton];
	container = [[NSView alloc] initWithFrame:containerFrame];
	_magnifyButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, NSMaxY(containerFrame) + 5, 32, 18)];
	[_magnifyButton setCell:[[[[[NSColorPanel sharedColorPanel] valueForKey:@"_magnifyButton"] cell] copy] autorelease]];
	[_magnifyButton setTarget:self];
	[_magnifyButton setAction:@selector(magnify:)];
	[_magnifyButton setAutoresizingMask:NSViewMaxYMargin | NSViewMinYMargin];
	[[self contentView] addSubview:_magnifyButton];
	_colorWell = [[NSColorWell alloc] initWithFrame:NSMakeRect(32, NSMaxY(containerFrame) + 5, NSWidth(containerFrame) - 39, 24)];
	[_colorWell setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
	[_colorWell setBordered:NO];
	[[self contentView] addSubview:_colorWell];
	[container setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	[[self contentView] addSubview:container];
	[[self contentView] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	pickers = [[NSMutableArray alloc] initWithCapacity:10];
	views = [[NSMutableArray alloc] initWithCapacity:10];
	//warning: private methods and classes!
	id enumerator = [[[NSColorPanel sharedColorPanel] _colorPickers] objectEnumerator], current;
	while(current = [enumerator nextObject])
	{
		id picker = [[[[current class] alloc] initWithPickerMask:NSColorPanelAllModesMask colorPanel:(NSColorPanel *)self] autorelease];
		[pickers addObject:picker];
		[views addObject:[picker provideNewView:YES]];
	}
	if([pickers count] != [views count])
	{
		NSLog(@"Bad!");
	}
	[_NSColorPanelToolbar attachToolbarToColorPanel:(NSColorPanel *)self];
	[self setColor:[NSColor blackColor]];
	[self setShowsAlpha:NO];
	[self setTitle:NSLocalizedString(@"Colors", @"Colors")];
	[[self standardWindowButton:NSWindowCloseButton] setHidden:YES];
	[[self standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
	[[self standardWindowButton:NSWindowZoomButton] setHidden:YES];
	[[self standardWindowButton:NSWindowToolbarButton] setHidden:YES];
	return self;
}

- _colorPickers
{
	return pickers;
}

- (void)setColor:(NSColor *)col
{
	NSColor *aColor = [col colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	if([aColor isEqual:color]) { return; }
	[aColor retain];
	[color release];
	color = aColor;
	[self setAlpha:[color alphaComponent]];
	[_colorWell setColor:color];
	[pickers setValue:color forKey:@"color"];
}

- color
{
	return color;
}

- (BOOL)showsAlpha
{
	return showsAlpha;
}

- (void)setShowsAlpha:(BOOL)shows
{
	showsAlpha = shows;
	[self setAlpha:[color alphaComponent]];
	[alphaSlider setEnabled:shows];
	[alphaField setEnabled:shows];
	[percentLabel setTextColor:shows ? [NSColor blackColor] : [NSColor disabledControlTextColor]];
	[opacityLabel setTextColor:shows ? [NSColor blackColor] : [NSColor disabledControlTextColor]];
}

- (IBAction)cancel:sender
{
	[NSApp abortModal];
}

- (IBAction)apply:sender
{
	[NSApp stopModal];
}

- (NSColor *)run
{
	NSColor *oldColor = [color retain];
	NSWindow *mainWindow = [NSApp mainWindow];
	int code = [NSApp runModalForWindow:self];
	if(code == NSRunAbortedResponse)
	{
		[self setColor:[oldColor autorelease]];
	}
	[self close];
	[mainWindow makeMainWindow];
	[mainWindow makeKeyWindow];
	return color;
}

- (int)mode
{
	return mode;
}

- (id)_keyViewFollowingPickerViews
{
	return container;
}

- (float)alpha
{
	return [[self color] alphaComponent];
}

- (void)activatePicker:(id<NSColorPickingCustom, NSColorPickingDefault>)picker
{
	//This cast might not be safe.  Maybe.
	if([(id<NSObject>)picker conformsToProtocol:@protocol(NSColorPickingCustom)])
	{
		[currentView removeFromSuperview];
		[currentView autorelease];
		currentView = [[picker provideNewView:NO] retain];
		[currentView setFrame:NSMakeRect(0, 0, NSWidth([container frame]), NSHeight([container frame]))];
		[picker viewSizeChanged:self];
		[picker setColor:color];
		[container addSubview:currentView];
		[container setNeedsDisplay:YES];
	}
}

- (void)setMode:(int)aMode
{
	mode = aMode;
	id enumerator = [pickers objectEnumerator], current;
	while(current = [enumerator nextObject])
	{
		if([current supportsMode:mode])
		{
			[self activatePicker:current];
		}
	}
}

- (void)_switchViewForToolbarItem:(id)item
{
	id<NSColorPickingCustom, NSColorPickingDefault> picker = [item representedObject];
	[self activatePicker:picker];
}

- (IBAction)magnify:sender
{
	NSColor *oldColor = [[NSColorPanel sharedColorPanel] color];
	[[NSColorPanel sharedColorPanel] _magnify:nil];
	[self setColor:[[NSColorPanel sharedColorPanel] color]];
	[[NSColorPanel sharedColorPanel] setColor:oldColor];
}

- (void)_setMinPickerContentSize:(NSSize)size
{
	
}

- _toolTipForColorPicker:picker
{
	return [[NSColorPanel sharedColorPanel] _toolTipForColorPicker:picker];	
}

@end
