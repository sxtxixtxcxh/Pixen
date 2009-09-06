//
//  PXModalColorPanel.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.11.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColorPanel(Modality)
- (BOOL)isModal;
@end

@interface PXModalColorPanel : NSPanel {
	NSColor *color;
	BOOL showsAlpha;
	NSSlider *alphaSlider;
	NSTextField *alphaField, *percentLabel, *opacityLabel;
	NSMutableArray *pickers, *views;
	int mode;
	NSView *container, *currentView;
	NSButton *cancelButton, *applyButton, *_magnifyButton;
	id _colorWell;
}
- (BOOL)isModal;
+ (PXModalColorPanel *)sharedColorPanel;
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag;
- _colorPickers;
- (void)setColor:(NSColor *)aColor;
- color;
- (BOOL)showsAlpha;
- (void)setShowsAlpha:(BOOL)shows;
- (NSColor *)run;
- (int)mode;
- (void)activatePicker:(id<NSColorPickingCustom, NSColorPickingDefault>)picker;
- (void)setMode:(int)aMode;
- (void)_switchViewForToolbarItem:(id)item;
- _toolTipForColorPicker:picker;
@end
