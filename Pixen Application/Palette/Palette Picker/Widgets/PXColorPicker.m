//
//  PXColorPicker.m
//  PXColorPicker
//
//  Created by Andy Matuschak on 7/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXColorPicker.h"

#import "PXPaletteView.h"
#import "PXPaletteViewController.h"
#import "PXPaletteViewScrollView.h"

int kPXColorPickerMode = 23421337;

@implementation PXColorPicker

// NSColorPicker overrides
- (void)alphaControlAddedOrRemoved:(id)sender {}
- (void)attachColorList:(NSColorList *)colorList {}
- (void)detachColorList:(NSColorList *)colorList {}
- (void)setColor:(NSColor *)aColor {}
- (void)setMode:(NSColorPanelMode)mode {}

- (NSImage *)provideNewButtonImage
{
	return _icon;
}

- (BOOL)supportsMode:(NSColorPanelMode)mode
{
	return kPXColorPickerMode == mode;
}

- (NSColorPanelMode)currentMode
{
	return kPXColorPickerMode;
}

- (void)viewSizeChanged:(id)sender
{
	[_vc.view setFrameOrigin:NSZeroPoint];
}

- (NSString *)buttonToolTip
{
	return @"Pixen Colors";
}

- (void)insertNewButtonImage:(NSImage *)newButtonImage in:(NSButtonCell *)buttonCell
{
	[buttonCell setImage:newButtonImage];
}

- (NSView *)provideNewView:(BOOL)initialRequest
{
	[_vc.paletteView performSelector:@selector(setupLayer) withObject:nil afterDelay:0.0f];
	[_vc reloadData];
	
	return _vc.view;
}

- (id)initWithPickerMask:(NSUInteger)mask colorPanel:(NSColorPanel *)owningColorPanel
{
	if (!(mask & NSColorPanelRGBModeMask))
		return nil; // We only support RGB mode.
	
	self = [super initWithPickerMask:mask colorPanel:owningColorPanel];
	
	_icon = [[NSImage imageNamed:@"colorpalette"] retain];
	
	_vc = [[PXPaletteViewController alloc] init];
	[_vc loadView];
	[_vc paletteView].delegate = self;
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	
	if ([defs objectForKey:PXColorPickerPaletteViewSizeKey] == nil)
		[defs setInteger:NSRegularControlSize forKey:PXColorPickerPaletteViewSizeKey];
	
	[ (PXPaletteViewScrollView *) ([_vc.paletteView enclosingScrollView]) setControlSize:[defs integerForKey:PXColorPickerPaletteViewSizeKey]];
	
	return self;
}

- (void)dealloc
{
	[_icon release];
	[_vc release];
	[super dealloc];
}

- (void)paletteViewSizeChangedTo:(NSControlSize)size
{
	[[NSUserDefaults standardUserDefaults] setInteger:size forKey:PXColorPickerPaletteViewSizeKey];
}

- (void)useColorAtIndex:(unsigned)index event:(NSEvent *)event
{
	PXPalette *palette = [_vc.paletteView palette];
	[[self colorPanel] setShowsAlpha:YES];
	[[self colorPanel] setColor:PXPalette_colorAtIndex(palette, index)];
}

@end
