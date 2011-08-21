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

@synthesize toolName, patternFileName, delegate;

- (void)awakeFromNib
{
	[editorView setDelegate:self];
	[[promptField cell] setBackgroundStyle:NSBackgroundStyleRaised];
	
	SBCenteringClipView *clip = [[SBCenteringClipView alloc] initWithFrame:[[scrollView contentView] frame]];
	[clip setBackgroundColor:[NSColor lightGrayColor]];
	[clip setCopiesOnScroll:NO];
	
	[(NSScrollView *)scrollView setContentView:clip];
	[clip release];
	
	[scrollView setDocumentView:editorView];
	
	[[self window] setTitle:[NSLocalizedString(@"Pattern Editor: ", @"Pattern Editor:") stringByAppendingString:toolName]];
	
	[self reloadPatterns];
}

- (void)setPattern:(PXPattern *)pattern
{
	if (pattern == _pattern)
		return;
	
	[self loadWindow];
	
	[_pattern release];
	_pattern = [pattern copy];
	
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
	PXPattern *pattern = [[_pattern copy] autorelease];
	[self addPattern:pattern];
	
	if ([delegate respondsToSelector:@selector(patternEditor:finishedWithPattern:)])
		[delegate patternEditor:self finishedWithPattern:pattern];
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
	self = [super initWithWindowNibName:@"PXPatternEditor"];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(patternsChanged:)
													 name:PXPatternsChangedNotificationName
												   object:nil];
		
		[self setPatternFileName:GetPixenPatternFile()];
	}
	return self;
}

- (void)patternView:(PXPatternEditorView *)pv changedPattern:(PXPattern *)pattern
{
	[self setPattern:pattern];
	
	if ([delegate respondsToSelector:@selector(patternEditor:finishedWithPattern:)])
		[delegate patternEditor:self finishedWithPattern:pattern];
}

- (void)reloadPatterns
{
	BOOL isDirectory;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
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
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:NSLocalizedString(@"Delete", @"DELETE")];
	
	NSButton *button = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"CANCEL")];
	[button setKeyEquivalent:@"\r"];
	
	[alert setMessageText:NSLocalizedString(@"Really delete the selected pattern?", @"PATTERN_DELETE_PROMPT")];
	[alert setInformativeText:NSLocalizedString(@"This operation cannot be undone.", @"PATTERN_DELETE_INFORMATIVE_TEXT")];
	
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:@selector(deleteSheetDidEnd:returnCode:contextInfo:)
						contextInfo:nil];
}

- (void)patternsChanged:(NSNotification *)notification
{
	
}

- (void)patternItemWasDoubleClicked:(PXPatternItem *)item
{
	PXPattern *pattern = [item representedObject];
	[self setPattern:pattern];
	
	if ([delegate respondsToSelector:@selector(patternEditor:finishedWithPattern:)])
		[delegate patternEditor:self finishedWithPattern:pattern];
}

- (void)addPattern:(PXPattern *)pattern
{
	[patternsController addObject:pattern];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternsChangedNotificationName
														object:self
													  userInfo:nil];
	
	[NSKeyedArchiver archiveRootObject:[patternsController arrangedObjects]
								toFile:patternFileName];
}

- (void)removePattern:(PXPattern *)pattern
{
	[patternsController removeObject:pattern];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternsChangedNotificationName
														object:self
													  userInfo:nil];
	
	[NSKeyedArchiver archiveRootObject:[patternsController arrangedObjects]
								toFile:patternFileName];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[patternFileName release];
	[super dealloc];
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
