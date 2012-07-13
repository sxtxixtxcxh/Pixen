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
	IBOutlet PXPaletteView *paletteView;
	NSButton *addColorButton;
	NSTextField *infoField;
	IBOutlet PXPaletteSelector *paletteSelector;
	PXNamePrompter *namePrompter;
	id delegate;
}

@property (nonatomic, readonly) IBOutlet PXPaletteView *paletteView;
@property (nonatomic, assign) IBOutlet NSButton *addColorButton;
@property (nonatomic, assign) IBOutlet NSTextField *infoField;

@property (nonatomic, assign) id delegate;

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
