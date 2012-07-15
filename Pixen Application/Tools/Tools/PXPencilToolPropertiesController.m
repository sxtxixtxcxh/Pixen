//
//  PXPencilToolPropertiesController.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXPencilToolPropertiesController.h"
#import "PXCanvasDocument.h"
#import "PXPattern.h"
#import "PXCanvasController.h"
#import "PXNotifications.h"
#import "PXPatternEditorController.h"

@implementation PXPencilToolPropertiesController

@synthesize lineThickness, pattern = drawingPattern, toolName;

- (NSString *)nibName
{
    return @"PXPencilToolPropertiesView";
}

- (void)setPattern:(PXPattern *)pattern
{
	if (drawingPattern != pattern) {
		drawingPattern = pattern;
		
		[lineThicknessField setEnabled:NO];
		[clearButton setEnabled:YES];
	}
}

- (void)patternEditor:(id)editor finishedWithPattern:(PXPattern *)pattern
{
	if (pattern == nil)
		return;
	
	[self setPattern:pattern];
}

- (NSSize)patternSize
{
	if (drawingPattern != nil) {
		return [drawingPattern size];
	}
	
	return NSZeroSize;
}

- (NSArray *)drawingPoints
{
	return [drawingPattern pointsInPattern];
}

- (IBAction)clearPattern:(id)sender
{
	drawingPattern = nil;
	
	[lineThicknessField setEnabled:YES];
	[clearButton setEnabled:NO];
}

- (IBAction)showPatterns:(id)sender
{
	if (drawingPattern == nil) {
		PXPattern *pattern = [[PXPattern alloc] init];
		[pattern setSize:NSMakeSize([self lineThickness], [self lineThickness])];
		
		int x, y;
		for (x=0; x<[self lineThickness]; x++) {
			for (y=0; y<[self lineThickness]; y++) {
				[pattern addPoint:NSMakePoint(x, y)];
			}
		}
		
		[self setPattern:pattern];
	}
	
	if (!patternEditor) {
		patternEditor = [[PXPatternEditorController alloc] init];
		patternEditor.delegate = self;
		patternEditor.toolName = toolName;
	}
	
	[patternEditor setPattern:drawingPattern];
	[patternEditor showWindow:self];
}

- (void)awakeFromNib
{
	[self clearPattern:nil];
}

- (id)init
{
	self = [super init];
	if (self) {
		self.lineThickness = 1;
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
