//
//  PXPaletteSelector.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

@interface PXPaletteSelector : NSObject
{
  @private
	NSMutableArray *_palettes;
}

@property (nonatomic, getter=isEnabled, assign) BOOL enabled;

@property (nonatomic, weak) IBOutlet NSPopUpButton *selectionPopup;

@property (nonatomic, weak) IBOutlet id delegate;

- (NSArray *)palettes;

- (void)showPalette:(PXPalette *)palette;
- (PXPalette *)reloadDataWithCurrentPalette:(PXPalette *)currentPalette;

- (IBAction)selectionChanged:(id)sender;

@end


@interface NSObject (PXPaletteSelectorDelegate)

- (void)paletteSelector:(PXPaletteSelector *)selector selectionDidChangeTo:(PXPalette *)palette;

@end
