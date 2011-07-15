//
//  PXPalettePanel.m
//  Pixen
//
//  Created by Joe Osborn on 2005.08.12.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXPalettePanel.h"
#import "PXPaletteView.h"
#import "PXPaletteViewController.h"
#import "PXToolSwitcher.h"
#import "PXToolPaletteController.h"
#import "PXPanelManager.h"

@implementation PXPalettePanel

+ (id)popWithPalette:(PXPalette *)palette fromWindow:(NSWindow *)window
{
	id panel = [[self alloc] initWithPalette:palette];
	
	static NSPoint previousPoint = { 0.0f, 0.0f };
	static NSWindow *previousWindow = nil;
	
	NSPoint topLeft = NSMakePoint(NSMaxX([window frame]), NSMaxY([window frame]));
	
	if (previousWindow == window) {
		topLeft = previousPoint;
	}
	
	previousWindow = window;
	
	[panel setFrame:[window frame] display:NO];
	previousPoint = [panel cascadeTopLeftFromPoint:topLeft];
	
	return [panel autorelease];
}

- (id)initWithPalette:(PXPalette *)palette
{
	self = [super initWithContentRect:NSMakeRect(0.0f, 0.0f, 270.0f, 283.0f)
							styleMask:NSUtilityWindowMask | NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
							  backing:NSBackingStoreBuffered
								defer:NO];
	
	[self setBecomesKeyOnlyIfNeeded:YES];
	[self setReleasedWhenClosed:NO];
	
	_vc = [[PXPaletteViewController alloc] init];
	[_vc setDelegate:self];
	[_vc loadView];
	[_vc paletteView].delegate = self;
	
	[self setContentView:_vc.view];
	[_vc reloadDataAndShow:palette];
	
	return self;
}

- (void)dealloc
{
    [_vc release];
    [super dealloc];
}

- (PXPaletteView *)paletteView
{
	return _vc.paletteView;
}

- (void)paletteViewControllerDidShowPalette:(PXPalette *)palette
{
	[self setTitle:palette->name];
}

- (void)useColorAtIndex:(unsigned)index
{
	PXToolSwitcher *switcher = [[PXToolPaletteController sharedToolPaletteController] leftSwitcher];
	
	if ([NSEvent pressedMouseButtons] == 2 || ([NSEvent modifierFlags] & NSControlKeyMask)) {
		switcher = [[PXToolPaletteController sharedToolPaletteController] rightSwitcher];
	}
	
	[switcher setColor:PXPalette_colorAtIndex([_vc.paletteView palette], index)];
}

@end
