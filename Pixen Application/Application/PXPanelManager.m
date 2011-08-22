//
//  PXPanelManager.m
//  Pixen
//

#import "PXPanelManager.h"
#import "PXWelcomeController.h"
#import "PXAboutController.h"
#import "PXToolPaletteController.h"
#import "PXToolPropertiesManager.h"
#import "PXPreferencesController.h"
#import "PXInfoPanelController.h"
#import "PXPreviewController.h"
#import "PXSpriteSheetExporter.h"
#import "PXPalette.h"
#import "PXPaletteView.h"
#import "PXPaletteViewScrollView.h"
#import "PXPalettePanel.h"

@implementation PXPanelManager

static PXPanelManager *sharedManager = nil;

+(id) sharedManager
{
	if (sharedManager == nil) {
		sharedManager = [[self alloc] init];
	}
	return sharedManager;
}

- (id) init
{
	if ( ! (self = [super init] ) ) 
		return nil;
	
	sharedManager = self;
	_palettePanels = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dealloc
{
	[_palettePanels release];
	[super dealloc];
}
- (void)restorePanelStates
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// Open some panels if the user have let them open the last time
	if ( [defaults boolForKey:PXLeftToolPropertiesIsOpenKey] ) {
		[self showLeftToolProperties:self];
	}
	if ( [defaults boolForKey:PXRightToolPropertiesIsOpenKey] ) {
		[self showRightToolProperties:self];
	}
	
	if ( [defaults boolForKey:PXInfoPanelIsOpenKey] ) {
		[self showInfo:self];
	}
	
	if ( [defaults boolForKey:PXPreviewWindowIsOpenKey] ) {
		[self showPreviewPanel:self];
	}
	
	//Always display toolPanel
	[self showToolPalette:self];
	
	NSArray *systemPalettes = [PXPalette systemPalettes];
	NSArray *userPalettes = [PXPalette userPalettes];
	
	NSArray *palettePanels = [defaults objectForKey:PXPalettePanelsKey];
	
	for (NSDictionary *current in palettePanels)
	{
		BOOL isSystemPalette = [[current objectForKey:PXPalettePanelIsSystemPaletteKey] boolValue];
		NSUInteger index = [[current objectForKey:PXPalettePanelPaletteIndexKey] unsignedIntegerValue];
		int viewSize = [[current objectForKey:PXPalettePanelPaletteViewSizeKey] intValue];
		
		PXPalette *palette = nil;
		
		if ((isSystemPalette && index >= [systemPalettes count]) ||
			(!isSystemPalette && index >= [userPalettes count]))
		{
			palette = [systemPalettes objectAtIndex:0];
		}
		else
		{
			palette = isSystemPalette ? [systemPalettes objectAtIndex:index] : [userPalettes objectAtIndex:index];
		}
		
		PXPalettePanel *panel = [[PXPalettePanel alloc] initWithPalette:palette];
		
		[self addPalettePanel:panel];
		[panel release];
		
		[panel setFrame:NSRectFromString([current objectForKey:PXPalettePanelFrameKey])
				display:NO];
		
		[(PXPaletteViewScrollView *)[[panel paletteView] enclosingScrollView] setControlSize:viewSize];
		
		[panel makeKeyAndOrderFront:self];
	}
	
	// make sure this gets document open/close notification
	[PXSpriteSheetExporter sharedSpriteSheetExporter];
}

- (void)archivePanelStates
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL boolTmp;
	
	//Panel leftToolPropertiesPanel
	boolTmp = [[self leftToolPropertiesPanel] isVisible];
	[defaults setBool:boolTmp forKey:PXLeftToolPropertiesIsOpenKey];
	
	//rightToolPropertiesPanel
	boolTmp= [[self rightToolPropertiesPanel] isVisible];
	[defaults setBool:boolTmp forKey:PXRightToolPropertiesIsOpenKey];
	
	//info Panel
	boolTmp = [[self infoPanel] isVisible];
	[defaults setBool:boolTmp forKey:PXInfoPanelIsOpenKey];
	
	// Popout color panels
	NSMutableArray *archivedPalettePanels = [NSMutableArray array];
	
	NSArray *systemPalettes = [PXPalette systemPalettes];
	NSArray *userPalettes = [PXPalette userPalettes];
	
	for (PXPalettePanel *panel in _palettePanels)
	{
		if (![panel isVisible])
			continue;
		
		NSMutableDictionary *panelInfo = [NSMutableDictionary dictionary];
		[panelInfo setObject:NSStringFromRect([panel frame]) forKey:PXPalettePanelFrameKey];
		[panelInfo setObject:[NSNumber numberWithLong:[[panel paletteView] controlSize]] forKey:PXPalettePanelPaletteViewSizeKey];
		
		// Now we've got to identify the palette and see how we're going to classify it.
		PXPalette *palette = [[panel paletteView] palette];
		
		NSUInteger i;
		BOOL found = NO;
		
		for (i = 0; i < [systemPalettes count]; i++)
		{
			if ([[systemPalettes objectAtIndex:i] isEqual:palette])
			{
				found = YES;
				[panelInfo setObject:[NSNumber numberWithBool:YES] forKey:PXPalettePanelIsSystemPaletteKey];
				[panelInfo setObject:[NSNumber numberWithUnsignedInteger:i] forKey:PXPalettePanelPaletteIndexKey];
				break;
			}
		}
		
		if (!found) // Check the user palettes.
		{
			for (i = 0; i < [userPalettes count]; i++)
			{
				if ([[userPalettes objectAtIndex:i] isEqual:palette])
				{
					found = YES;
					[panelInfo setObject:[NSNumber numberWithBool:NO] forKey:PXPalettePanelIsSystemPaletteKey];
					[panelInfo setObject:[NSNumber numberWithUnsignedInteger:i] forKey:PXPalettePanelPaletteIndexKey];
				}
			}
			
			if (!found) // Okay, if it's -still- not found, we skip it.
				continue;
		}
		
		[archivedPalettePanels addObject:panelInfo];
	}
	
	[defaults setObject:archivedPalettePanels forKey:PXPalettePanelsKey];
	[defaults synchronize];
}

- (void)addPalettePanel:(NSPanel *)panel
{
	[_palettePanels addObject:panel];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(windowWillClose:)
												 name:NSWindowWillCloseNotification
											   object:panel];
}

- (void)windowWillClose:(NSNotification *)notification
{
	PXPalettePanel *panel = [notification object];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSWindowWillCloseNotification
												  object:panel];
	
	[self performSelector:@selector(removePalettePanel:)
			   withObject:panel
			   afterDelay:0.0f];
}

- (void)removePalettePanel:(NSPanel *)panel
{
	if ([_palettePanels containsObject:panel]) {
		[_palettePanels removeObject:panel];
	}
}

- (void)show:panel
{
	[panel makeKeyAndOrderFront:self];
}

- (void)hide:panel
{
	[panel performClose:self];
}

- (void)toggle:panel
{
	if ([panel isVisible]) {
		[self hide:panel];
	} else {
		[self show:panel];
	}
}

- (NSPanel *)leftToolPropertiesPanel
{
	return (NSPanel *) [PXToolPropertiesManager leftToolPropertiesManager].window;
}

- (NSPanel *)rightToolPropertiesPanel
{
	return (NSPanel *) [PXToolPropertiesManager rightToolPropertiesManager].window;
}

- (NSPanel *)preferencesPanel
{
	return (NSPanel *)[[PXPreferencesController sharedPreferencesController] window];
}

- (NSPanel *)infoPanel
{
	return [[PXInfoPanelController sharedInfoPanelController] infoPanel];
}

- (NSPanel *)welcomePanel
{
	return (NSPanel *)[[PXWelcomeController sharedWelcomeController] window];
}

- (NSPanel *)toolPalettePanel
{
	return [[PXToolPaletteController sharedToolPaletteController] toolPanel];
}

- (NSPanel *)spriteSheetExporterPanel
{
	return (NSPanel *)[[PXSpriteSheetExporter sharedSpriteSheetExporter] window];
}

- (NSPanel *)previewPanel
{
	return (NSPanel *)[[PXPreviewController sharedPreviewController] window];
}

- (IBAction)showLeftToolProperties: (id)sender
{
	[self show:[self leftToolPropertiesPanel]];
}

- (IBAction)toggleLeftToolProperties: (id)sender
{
	[self toggle:[self leftToolPropertiesPanel]];
}

- (IBAction)showRightToolProperties: (id)sender
{
	[self show:[self rightToolPropertiesPanel]];
}

- (IBAction)toggleRightToolProperties: (id)sender
{
	[self toggle:[self rightToolPropertiesPanel]];
}

- (IBAction)showPreferences: (id)sender
{
	[[PXPreferencesController sharedPreferencesController] showWindow:nil];
}

- (IBAction)showInfo: (id)sender
{
	[self show:[self infoPanel]];
}

- (IBAction)showWelcome: (id)sender
{
	[[self welcomePanel] center];
	[self show:[self welcomePanel]];
}

- (IBAction)showAbout: (id)sender
{
	[[PXAboutController sharedAboutController] showPanel:self];
}

- (IBAction)showToolPalette: (id)sender
{
	[self show:[self toolPalettePanel]];
}

- (IBAction)showSpriteSheetExporter: (id)sender
{
  [[PXSpriteSheetExporter sharedSpriteSheetExporter] recacheDocumentRepresentations];
	[self show:[self spriteSheetExporterPanel]];
}

- (IBAction)showPreviewPanel: (id)sender
{
	[self show:[self previewPanel]];
}

@end
