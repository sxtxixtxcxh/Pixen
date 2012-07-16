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
	PXPattern *drawingPattern;
	PXPatternEditorController *patternEditor;
	int lineThickness;
	NSString *toolName;
}

@property (nonatomic, weak) IBOutlet NSTextField *lineThicknessField;
@property (nonatomic, weak) IBOutlet NSButton *patternButton;
@property (nonatomic, weak) IBOutlet NSButton *clearButton;

@property (nonatomic, assign) int lineThickness;
@property (nonatomic, strong) PXPattern *pattern;

@property (nonatomic, copy) NSString *toolName;

- (NSSize)patternSize;
- (NSArray *)drawingPoints;

- (IBAction)showPatterns:(id)sender;
- (IBAction)clearPattern:(id)sender;

@end
