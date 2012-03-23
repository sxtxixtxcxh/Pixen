//
//  PXSpriteSheetExporter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXSpriteSheetExporter : NSWindowController
{
  @private
	NSImageView *sheetImageView;
	NSArrayController *documentRepresentationsController;
	BOOL closeOnEndSheet;
}

@property (nonatomic, assign) IBOutlet NSImageView *sheetImageView;

@property (nonatomic, assign) IBOutlet NSArrayController *documentRepresentationsController;

+ (id)sharedSpriteSheetExporter;

- (IBAction)export:(id)sender;

- (IBAction)updatePreview:(id)sender;

@end
