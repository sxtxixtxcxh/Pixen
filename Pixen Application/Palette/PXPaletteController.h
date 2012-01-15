//
//  PXPaletteController.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@class PXDocument, PXPalette, PXPaletteView;

typedef enum {
	PXPaletteModeRecent,
	PXPaletteModeFrequency
} PXPaletteMode;

@interface PXPaletteController : NSViewController
{
	PXPaletteMode _mode;
	PXPalette *_frequencyPalette, *_recentPalette;
    PXPaletteView *_paletteView;
    PXDocument *_document;
}

@property (nonatomic, assign) IBOutlet PXPaletteView *paletteView;

@property (nonatomic, assign) PXDocument *document;

- (BOOL)isPaletteIndexKey:(NSEvent *)event;

- (IBAction)useMostRecentColors:(id)sender;
- (IBAction)useMostFrequentColors:(id)sender;

@end
