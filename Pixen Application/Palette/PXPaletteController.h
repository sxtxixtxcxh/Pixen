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
  @private
	PXPaletteMode _mode;
	PXPalette *_frequencyPalette, *_recentPalette;
	
	NSOperationQueue *_frequencyQueue;
	NSOperationQueue *_recentQueue;
}

@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, weak) IBOutlet PXPaletteView *paletteView;

@property (nonatomic, weak) PXDocument *document;

- (BOOL)isPaletteIndexKey:(NSEvent *)event;

- (IBAction)useMostRecentColors:(id)sender;
- (IBAction)useMostFrequentColors:(id)sender;

@end
