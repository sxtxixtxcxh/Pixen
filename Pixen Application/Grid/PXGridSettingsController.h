//
//  PXGridSettingsController.h
//  Pixen
//

#import <AppKit/AppKit.h>

@interface NSObject(PXGridSettingsPrompterDelegate)

- (void)gridSettingsController:(id)aController
			   updatedWithSize:(NSSize)aSize
						 color:(NSColor *)color
					shouldDraw:(BOOL)shouldDraw;

@end

@interface PXGridSettingsController : NSWindowController
{
  @private
	IBOutlet NSColorWell *colorWell;
	IBOutlet NSButton *shouldDrawCheckBox;
	IBOutlet NSTextField *colorLabel, *sizeLabel;
	
	int width, height;
	NSColor *color;
	id delegate;
	BOOL shouldDraw;
}

@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, retain) NSColor *color;
@property (nonatomic, assign) BOOL shouldDraw;

@property (nonatomic, assign) id delegate;

- (IBAction)update:(id)sender;
- (IBAction)useAsDefaults:(id)sender;
- (IBAction)displayHelp:(id)sender;

@end
