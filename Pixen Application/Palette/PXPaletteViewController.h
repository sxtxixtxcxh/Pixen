//
//  PXPaletteViewController.h
//  Pixen
//
//  Created by Matt Rajca on 7/2/11.
//  Copyright 2011-2012 Matt Rajca. All rights reserved.
//

#import "PXPalette.h"

@class PXPaletteView, PXPaletteSelector, PXNamePrompter;

@interface PXPaletteViewController : NSViewController
{
  @private
	PXNamePrompter *namePrompter;
}

@property (nonatomic, weak) IBOutlet PXPaletteSelector *paletteSelector;
@property (nonatomic, weak) IBOutlet PXPaletteView *paletteView;
@property (nonatomic, weak) IBOutlet NSButton *addColorButton;
@property (nonatomic, weak) IBOutlet NSTextField *infoField;

@property (nonatomic, unsafe_unretained) id delegate;

- (IBAction)addColor:(id)sender;

- (IBAction)installPalette:sender;
- (IBAction)exportPalette:sender;
- (IBAction)duplicatePalette:sender;
- (IBAction)deletePalette:sender;
- (IBAction)newPalette:sender;
- (IBAction)renamePalette:sender;

- (void)reloadData;
- (void)reloadDataAndShow:(PXPalette *)palette;

- (void)showColorModificationInfo;

@end


@interface NSObject (PXPaletteViewControllerDelegate)

- (void)paletteViewControllerDidShowPalette:(PXPalette *)palette;

@end
