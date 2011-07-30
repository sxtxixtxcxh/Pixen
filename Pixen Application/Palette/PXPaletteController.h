//
//  PXPaletteController.h
//  Pixen
//
//  Created by Joe Osborn on 2007.12.12.
//  Copyright 2007 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXCanvas.h"
@class PXCanvas, PXDocument, PXPaletteView;

typedef enum {
  PXPaletteModeRecent,
  PXPaletteModeFrequency,
  PXPaletteModeColorList
} PXPaletteMode;

@interface PXPaletteController : NSViewController
{
  @private
	PXPaletteMode mode;
	PXDocument *document;
	int recentLimit;
	PXPalette *frequencyPalette, *recentPalette, *listPalette;
	IBOutlet PXPaletteView *paletteView;
}

- (BOOL)isPaletteIndexKey:(NSEvent *)event;
- (void)keyDown:(NSEvent *)event;

- (IBAction)useMostRecentColors:sender;
- (IBAction)useMostFrequentColors:sender;
- (IBAction)useColorListColors:sender;

- (void)refreshPalette:(NSNotification *)note;
- (void)updatePalette:(NSNotification *)note;

@end
