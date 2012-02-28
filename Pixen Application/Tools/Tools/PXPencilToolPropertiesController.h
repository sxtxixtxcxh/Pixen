//
//  PXPencilToolPropertiesController.h
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXToolPropertiesController.h"

@class PXPattern, PXPatternEditorController;

@interface PXPencilToolPropertiesController : PXToolPropertiesController
{
  @private
	IBOutlet NSTextField *lineThicknessField;
	IBOutlet NSButton *patternButton;
	IBOutlet NSButton *clearButton;
	
	PXPattern *drawingPattern;
	PXPatternEditorController *patternEditor;
	int lineThickness;
	NSString *toolName;
}

@property (nonatomic, assign) int lineThickness;
@property (nonatomic, retain) PXPattern *pattern;

@property (nonatomic, copy) NSString *toolName;

- (NSSize)patternSize;
- (NSArray *)drawingPoints;

- (IBAction)showPatterns:(id)sender;
- (IBAction)clearPattern:(id)sender;

@end
