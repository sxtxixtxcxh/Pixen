//
//  PXSelectPatternController.m
//  Pixen
//
//  Created by Matt on 2/23/13.
//
//

#import "PXSelectPatternController.h"

#import "PXPattern.h"
#import "PXPatternItem.h"
#import "PXPatternEditorController.h"
#import "PathUtilities.h"

@implementation PXSelectPatternController

@synthesize patternsController, collectionView, popover, delegate;

- (id)init
{
	self = [super initWithNibName:@"PXSelectPattern" bundle:nil];
	if (self) {
		
	}
	return self;
}

- (void)dealloc
{
	[collectionView removeObserver:self forKeyPath:@"selectionIndexes"];
}

- (void)awakeFromNib
{
	[self.collectionView addObserver:self forKeyPath:@"selectionIndexes" options:0 context:NULL];
	
	[self reloadPatterns];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"selectionIndexes"]) {
		NSUInteger index = [[self.collectionView selectionIndexes] firstIndex];
		
		if (index != NSNotFound) {
			PXPattern *pattern = [[patternsController arrangedObjects] objectAtIndex:index];
			
			[self.delegate selectPatternControllerDidChoosePattern:pattern];
			[self.popover close];
		}
	}
}

- (void)reloadPatterns
{
	BOOL isDirectory = NO;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *patternFileName = GetPixenPatternFile();
	
	if (![fileManager fileExistsAtPath:patternFileName isDirectory:&isDirectory] || isDirectory)
		return;
	
	[patternsController removeObjects:[patternsController arrangedObjects]];
	
	NSArray *p = [NSKeyedUnarchiver unarchiveObjectWithFile:patternFileName];
	
	if (p)
		[patternsController addObjects:p];
}

- (IBAction)closePopover:(id)sender
{
	[self.popover close];
}

- (IBAction)manage:(id)sender
{
	[[PXPatternEditorController sharedController] showWindow:nil];
}

@end
