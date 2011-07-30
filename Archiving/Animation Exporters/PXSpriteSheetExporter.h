//
//  PXSpriteSheetExporter.h
//  Pixen
//
//  Created by Ian Henderson on 12.08.05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PXSpriteSheetExporter : NSWindowController {
  @private
	IBOutlet NSTableView *animationsTable;
	IBOutlet NSImageView *sheetImageView;
	NSArray *documentRepresentations;
	BOOL closeOnEndSheet;
}

+ (id)sharedSpriteSheetExporter;

- (IBAction)export:(id)sender;

- (NSArray *)documentRepresentations;
- (IBAction)updatePreview:(id)sender;

- (void)recacheDocumentRepresentations;

@end
