//
//  PXSpriteSheetExporter.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXSpriteSheetExporter : NSWindowController < NSTableViewDataSource, NSWindowDelegate, NSWindowRestoration >
{
  @private
	BOOL closeOnEndSheet;
}

@property (nonatomic, weak) IBOutlet NSImageView *sheetImageView;

@property (nonatomic, strong) IBOutlet NSArrayController *documentRepresentationsController;

+ (PXSpriteSheetExporter *)sharedSpriteSheetExporter;

- (IBAction)export:(id)sender;

- (IBAction)updatePreview:(id)sender;

@end
