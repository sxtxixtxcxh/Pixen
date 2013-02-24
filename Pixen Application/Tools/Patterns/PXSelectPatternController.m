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
#import "PathUtilities.h"

@implementation PXSelectPatternController

@synthesize patternsController, popover, delegate;

- (id)init
{
	self = [super initWithNibName:@"PXSelectPattern" bundle:nil];
	if (self) {
		
	}
	return self;
}

- (void)awakeFromNib
{
	[self reloadPatterns];
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

- (void)patternItemWasDoubleClicked:(PXPatternItem *)item
{
	[delegate selectPatternControllerDidChoosePattern:[item representedObject]];
}

@end
