//
//  PXGridSettingsController.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXGridSettingsController : NSWindowController
{
    NSColorWell *_colorWell;
    NSButton *_shouldDrawCheckBox;
    NSTextField *_colorLabel;
    NSTextField *_sizeLabel;

    int _width;
    int _height;
    NSColor *_color;
    BOOL _shouldDraw;

    id _delegate;
}

@property (nonatomic, assign) IBOutlet NSColorWell *colorWell;
@property (nonatomic, assign) IBOutlet NSButton *shouldDrawCheckBox;
@property (nonatomic, assign) IBOutlet NSTextField *colorLabel;
@property (nonatomic, assign) IBOutlet NSTextField *sizeLabel;

@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, retain) NSColor *color;
@property (nonatomic, assign) BOOL shouldDraw;

@property (nonatomic, assign) id delegate;

- (IBAction)update:(id)sender;
- (IBAction)useAsDefaults:(id)sender;
- (IBAction)displayHelp:(id)sender;

@end


@interface NSObject (PXGridSettingsPrompterDelegate)

- (void)gridSettingsController:(PXGridSettingsController *)controller
			   updatedWithSize:(NSSize)size
						 color:(NSColor *)color
					shouldDraw:(BOOL)shouldDraw;

@end
