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

- (NSPanel *)infoPanel;
- (NSPanel *)welcomePanel;
- (NSPanel *)toolPalettePanel;
- (NSPanel *)previewPanel;
- (NSPanel *)spriteSheetExporterPanel;

- (IBAction)showPreferences:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)showWelcome:(id)sender;
- (IBAction)showAbout:(id)sender;
- (IBAction)showToolPalette:(id)sender;
- (IBAction)showLeftToolProperties:(id)sender;
- (IBAction)showRightToolProperties:(id)sender;
- (IBAction)showPreviewPanel:(id)sender;
- (IBAction)showSpriteSheetExporter:(id)sender;

- (IBAction)toggleLeftToolProperties:(id)sender;
- (IBAction)toggleRightToolProperties:(id)sender;

@end
