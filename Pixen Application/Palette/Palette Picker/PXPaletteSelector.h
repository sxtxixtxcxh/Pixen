//
//  PXPaletteSelector.h
//  Pixen
//
//  Created by Andy Matuschak on 7/8/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXPalette.h"

@class PXCanvasDocument;
@interface PXPaletteSelector : NSObject {
  @private
	IBOutlet NSPopUpButton *selectionPopup;
	IBOutlet id delegate;
	
	NSMutableArray *_palettes;
}

- (NSArray *)palettes;

- (void)showPalette:(PXPalette *)pal;
- (PXPalette *)reloadDataExcluding:(PXCanvasDocument *)aDoc withCurrentPalette:(PXPalette *)currentPalette;
- (IBAction)selectionChanged:sender;
- (void)setEnabled:(BOOL)enabled;

@end

@interface NSObject(PXPaletteSelectorDelegate)
- (void)paletteSelector:(PXPaletteSelector *)selector selectionDidChangeTo:(PXPalette *)palette;
@end