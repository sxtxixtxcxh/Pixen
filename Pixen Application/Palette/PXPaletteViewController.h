//
//  PXPaletteViewController.h
//  Pixen
//
//  Created by Matt Rajca on 7/2/11.
//  Copyright 2011 Matt Rajca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXPalette.h"

@class PXPaletteView, PXPaletteSelector;

@interface PXPaletteViewController : NSViewController {
  @private
	IBOutlet PXPaletteView *paletteView;
	NSButton *addColorButton;
	IBOutlet PXPaletteSelector *paletteSelector;
	IBOutlet NSPopUpButton *gearMenu;
	id namePrompter, delegate;
}

@property (nonatomic, readonly) IBOutlet PXPaletteView *paletteView;
@property (nonatomic, assign) IBOutlet NSButton *addColorButton;

@property (nonatomic, assign) id delegate;

- (IBAction)addColor:(id)sender;

- (IBAction)installPalette:sender;
- (IBAction)exportPalette:sender;
- (IBAction)duplicatePalette:sender;
- (IBAction)deletePalette:sender;
- (IBAction)displayHelp:sender;
- (IBAction)newPalette:sender;
- (IBAction)renamePalette:sender;

- (void)reloadData;
- (void)reloadDataAndShow:(PXPalette *)palette;

@end


@interface NSObject (PXPaletteViewControllerDelegate)

- (void)paletteViewControllerDidShowPalette:(PXPalette *)palette;

@end
