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
	NSProgressIndicator *_progressIndicator;
	PXPaletteMode _mode;
	PXPalette *_frequencyPalette, *_recentPalette;
	PXPaletteView *_paletteView;
	PXDocument *_document;
	
	//FIXME: evaluate thread-safety
	dispatch_queue_t _frequencyQueue;
	dispatch_queue_t _recentQueue;
}

@property (nonatomic, assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, assign) IBOutlet PXPaletteView *paletteView;

@property (nonatomic, assign) PXDocument *document;

- (BOOL)isPaletteIndexKey:(NSEvent *)event;

- (IBAction)useMostRecentColors:(id)sender;
- (IBAction)useMostFrequentColors:(id)sender;

@end
