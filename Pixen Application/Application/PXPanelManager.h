//
//  PXPanelManager.h
//  Pixen
//

#import <Foundation/NSObject.h>

#import <AppKit/NSNibDeclarations.h>

@class NSPanel;

@interface PXPanelManager : NSObject < NSWindowDelegate >
{
  @private
	NSMutableArray *_palettePanels;
}

//Singleton
+(id) sharedManager;

- (void)archivePanelStates;
- (void)restorePanelStates;

- (void)addPalettePanel:(NSPanel *)panel;
- (void)removePalettePanel:(NSPanel *)panel;

	//Accessors
- (NSPanel *)leftToolPropertiesPanel;
- (NSPanel *)rightToolPropertiesPanel;
- (NSPanel *)preferencesPanel;
- (NSPanel *)infoPanel;
- (NSPanel *)welcomePanel;
- (NSPanel *)toolPalettePanel;
- (NSPanel *)previewPanel;
- (NSPanel *)spriteSheetExporterPanel;

   //IBActions
- (IBAction)showPreferences: (id)sender;
- (IBAction)showInfo: (id)sender;
- (IBAction)showWelcome: (id)sender;
- (IBAction)showAbout: (id)sender;
- (IBAction)showToolPalette: (id)sender;
- (IBAction)showLeftToolProperties: (id)sender;
- (IBAction)showRightToolProperties: (id)sender;
- (IBAction)showPreviewPanel: (id)sender;
- (IBAction)showSpriteSheetExporter: (id)sender;

- (IBAction)toggleLeftToolProperties: (id)sender;
- (IBAction)toggleRightToolProperties: (id)sender;

@end
