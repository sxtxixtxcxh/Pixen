//
//  PXSpriteSheetExporter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXSpriteSheetExporter : NSWindowController
{
  @private
	BOOL closeOnEndSheet;
}

@property (nonatomic, weak) IBOutlet NSImageView *sheetImageView;

@property (nonatomic, strong) IBOutlet NSArrayController *documentRepresentationsController;

+ (id)sharedSpriteSheetExporter;

- (IBAction)export:(id)sender;

- (IBAction)updatePreview:(id)sender;

@end
