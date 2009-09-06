/* PXPaletteRestrictor */

#import <Cocoa/Cocoa.h>
#import "PXPalette.h"
@class PXCanvas;
@interface PXPaletteRestrictor : NSWindowController
{
	NSNumber *numberOfColors;
	PXPalette *palette, *chosenPalette;
	PXCanvas *canvas;
	NSWindow *hostWindow;
	IBOutlet id paletteSelector;
	
	BOOL transparency;
	BOOL mergeLayers;
	BOOL matteImage;
	NSColorWell *matteColor;
}
- numberOfColors;
- (void)setNumberOfColors:newNumber;
- (void)runRestrictionSheetForPalette:(PXPalette *)pal canvas:(PXCanvas *)canv inWindow:(NSWindow *)wind;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)restrictPressed:(id)sender;
@end
