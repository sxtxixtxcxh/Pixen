//
//  PXPatternEditorController.m
//  Pixen
//

#import "PXPatternEditorController.h"

#import "PathUtilities.h"
#import "PXDeleteCollectionView.h"
#import "PXPattern.h"
#import "PXPatternEditorView.h"
#import "PXPatternItem.h"
#import "SBCenteringClipView.h"

@implementation PXPatternEditorController

@synthesize patternsController, scrollView, editorView;

+ (id)sharedController
{
	static PXPatternEditorController *sharedInstance;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedInstance = [[PXPatternEditorController alloc] init];
	});
	
	return sharedInstance;
}

- (void)awakeFromNib
{
	SBCenteringClipView *clip = [[SBCenteringClipView alloc] initWithFrame:[[scrollView contentView] frame]];
	[clip setBackgroundColor:[NSColor lightGrayColor]];
	[clip setCopiesOnScroll:NO];
	
	[(NSScrollView *)scrollView setContentView:clip];
	
	[scrollView setDocumentView:editorView];
	
	[self reloadPatterns];
}

- (void)setPattern:(PXPattern *)pattern
{
	if (pattern == _pattern)
		return;
	
	_pattern = pattern;
	
	NSSize patternSize = [_pattern size];
	
	if (patternSize.width < 2)
		patternSize.width = 2;
	
	if (patternSize.height < 2)
		patternSize.height = 2;
	
	if (!NSEqualSizes([_pattern size], patternSize))
		[_pattern setSize:patternSize];
	
	if (editorView) {
		[editorView setFrame:NSMakeRect(0.0f, 0.0f, patternSize.width * 32.0f, patternSize.height * 32.0f)];
		[editorView setPattern:_pattern];
	}
}

- (IBAction)newPattern:(id)sender
{
	int line = 4;
	
	PXPattern *pattern = [[PXPattern alloc] init];
	[pattern setSize:NSMakeSize(line, line)];
	
	for (int x=0; x<line; x++) {
		for (int y=0; y<line; y++) {
			[pattern addPoint:NSMakePoint(x, y)];
		}
	}
	
	[self addPattern:pattern];
}

- (void)deleteSheetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn)
	{
		PXPattern *selectedPattern = [[patternsController selectedObjects] objectAtIndex:0];
		[self removePattern:selectedPattern];
	}
}

- (id)init
{
	return [super initWithWindowNibName:@"PXPatternEditor"];
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

- (void)deleteKeyPressedInCollectionView:(NSCollectionView *)view
{
	if ([patternsController selectionIndex] == NSNotFound)
		return;
	
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:NSLocalizedString(@"Delete", @"DELETE")];
	
	NSButton *button = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"CANCEL")];
	[button setKeyEquivalent:@"\r"];
	
	[alert setMessageText:NSLocalizedString(@"Are you sure you want to delete the selected pattern?", @"PATTERN_DELETE_PROMPT")];
	[alert setInformativeText:NSLocalizedString(@"This operation cannot be undone.", @"PATTERN_DELETE_INFORMATIVE_TEXT")];
	
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:@selector(deleteSheetDidEnd:returnCode:contextInfo:)
						contextInfo:nil];
}

- (void)patternItemWasDoubleClicked:(PXPatternItem *)item
{
#warning TODO: single click
	PXPattern *pattern = [item representedObject];
	[self setPattern:pattern];
}

- (void)addPattern:(PXPattern *)pattern
{
	[patternsController addObject:pattern];
	
	[NSKeyedArchiver archiveRootObject:[patternsController arrangedObjects]
								toFile:GetPixenPatternFile()];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternsChangedNotificationName
														object:self
													  userInfo:nil];
}

- (void)removePattern:(PXPattern *)pattern
{
	[patternsController removeObject:pattern];
	
	[NSKeyedArchiver archiveRootObject:[patternsController arrangedObjects]
								toFile:GetPixenPatternFile()];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternsChangedNotificationName
														object:self
													  userInfo:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard
{
	NSUInteger index = [indexes firstIndex];
	PXPattern *pattern = [[patternsController arrangedObjects] objectAtIndex:index];
	
	[pasteboard declareTypes:[NSArray arrayWithObject:PXPatternPboardType] owner:self];
	[pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:pattern] forType:PXPatternPboardType];
	
	return YES;
}

@end
