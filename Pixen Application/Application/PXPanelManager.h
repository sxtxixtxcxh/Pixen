//
//  PXPanelManager.h
//  Pixen
//

@interface PXPanelManager : NSObject < NSWindowDelegate >
{
  @private
	NSMutableArray *_palettePanels;
}

+ (id)sharedManager;

- (void)archivePanelStates;
- (void)restorePanelStates;

- (void)addPalettePanel:(NSPanel *)panel;
- (void)removePalettePanel:(NSPanel *)panel;

- (NSPanel *)welcomePanel;
- (NSPanel *)toolPalettePanel;

- (IBAction)showPreferences:(id)sender;
- (IBAction)showWelcome:(id)sender;
- (IBAction)showAbout:(id)sender;
- (IBAction)showToolPalette:(id)sender;
- (IBAction)showLeftToolProperties:(id)sender;
- (IBAction)showRightToolProperties:(id)sender;
- (IBAction)showPreviewPanel:(id)sender;
- (IBAction)showSpriteSheetExporter:(id)sender;
- (IBAction)showPatternEditor:(id)sender;

- (IBAction)toggleLeftToolProperties:(id)sender;
- (IBAction)toggleRightToolProperties:(id)sender;

@end
