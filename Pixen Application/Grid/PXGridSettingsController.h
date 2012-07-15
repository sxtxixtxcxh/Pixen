//
//  PXGridSettingsController.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXGridSettingsController : NSWindowController

@property (nonatomic, weak) IBOutlet NSColorWell *colorWell;
@property (nonatomic, weak) IBOutlet NSButton *shouldDrawCheckBox;
@property (nonatomic, weak) IBOutlet NSTextField *colorLabel;
@property (nonatomic, weak) IBOutlet NSTextField *sizeLabel;

@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, strong) NSColor *color;
@property (nonatomic, assign) BOOL shouldDraw;

@property (nonatomic, weak) id delegate;

- (IBAction)update:(id)sender;
- (IBAction)useAsDefaults:(id)sender;

@end


@interface NSObject (PXGridSettingsPrompterDelegate)

- (void)gridSettingsController:(PXGridSettingsController *)controller
			   updatedWithSize:(NSSize)size
						 color:(NSColor *)color
					shouldDraw:(BOOL)shouldDraw;

@end
