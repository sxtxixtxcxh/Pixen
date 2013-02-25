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

@synthesize collectionView, popover, delegate;

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
	[self.collectionView bind:@"content" toObject:[[PXPatternEditorController sharedController] patternsController] withKeyPath:@"arrangedObjects" options:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"selectionIndexes"]) {
		NSUInteger index = [[self.collectionView selectionIndexes] firstIndex];
		
		if (index != NSNotFound) {
			PXPattern *pattern = [[[[PXPatternEditorController sharedController] patternsController] arrangedObjects] objectAtIndex:index];
			
			[self.delegate selectPatternControllerDidChoosePattern:pattern];
			[self.popover close];
		}
	}
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
