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

@implementation PXPatternEditorController {
	NSArrayController *_patternsController;
	BOOL _loadedPatterns;
}

@synthesize collectionView, scrollView, editorView;

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
	[self.collectionView registerForDraggedTypes:@[ NSFilenamesPboardType ]];
	[self.collectionView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
	[self.collectionView addObserver:self forKeyPath:@"selectionIndexes" options:0 context:NULL];
	
	[editorView setDelegate:self];
	
	SBCenteringClipView *clip = [[SBCenteringClipView alloc] initWithFrame:[[scrollView contentView] frame]];
	[clip setBackgroundColor:[NSColor lightGrayColor]];
	[clip setCopiesOnScroll:NO];
	
	[(NSScrollView *)scrollView setContentView:clip];
	
	[scrollView setDocumentView:editorView];
	
	[self.collectionView bind:@"content" toObject:[self patternsController] withKeyPath:@"arrangedObjects" options:nil];
	[self.collectionView bind:@"selectionIndexes" toObject:[self patternsController] withKeyPath:@"selectionIndexes" options:nil];
}

- (NSArrayController *)patternsController
{
	if (!_loadedPatterns) {
		[self reloadPatterns];
	}
	
	return _patternsController;
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
		PXPattern *selectedPattern = [[_patternsController selectedObjects] objectAtIndex:0];
		[self removePattern:selectedPattern];
	}
}

- (id)init
{
	self = [super initWithWindowNibName:@"PXPatternEditor"];
	if (self) {
		_patternsController = [[NSArrayController alloc] init];
	}
	return self;
}

- (void)patternView:(PXPatternEditorView *)pv changedPattern:(PXPattern *)pattern
{
	[NSKeyedArchiver archiveRootObject:[_patternsController arrangedObjects]
								toFile:GetPixenPatternFile()];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternsChangedNotificationName
														object:self
													  userInfo:nil];
}

- (void)reloadPatterns
{
	BOOL isDirectory = NO;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *patternFileName = GetPixenPatternFile();
	
	if (![fileManager fileExistsAtPath:patternFileName isDirectory:&isDirectory] || isDirectory)
		return;
	
	[_patternsController removeObjects:[_patternsController arrangedObjects]];
	
	NSArray *p = [NSKeyedUnarchiver unarchiveObjectWithFile:patternFileName];
	
	if (p)
		[_patternsController addObjects:p];
	
	_loadedPatterns = YES;
}

- (void)deleteKeyPressedInCollectionView:(NSCollectionView *)view
{
	if ([_patternsController selectionIndex] == NSNotFound)
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"selectionIndexes"]) {
		NSUInteger index = [[self.collectionView selectionIndexes] firstIndex];
		
		if (index != NSNotFound) {
			PXPattern *pattern = [[_patternsController arrangedObjects] objectAtIndex:index];
			[self setPattern:pattern];
		}
		else {
			[self setPattern:nil];
		}
	}
}

- (void)addPattern:(PXPattern *)pattern
{
	[[self patternsController] addObject:pattern];
	
	[NSKeyedArchiver archiveRootObject:[_patternsController arrangedObjects]
								toFile:GetPixenPatternFile()];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternsChangedNotificationName
														object:self
													  userInfo:nil];
}

- (void)removePattern:(PXPattern *)pattern
{
	[_patternsController removeObject:pattern];
	
	[NSKeyedArchiver archiveRootObject:[_patternsController arrangedObjects]
								toFile:GetPixenPatternFile()];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternsChangedNotificationName
														object:self
													  userInfo:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[collectionView removeObserver:self forKeyPath:@"selectionIndexes"];
}

- (NSArray *)collectionView:(NSCollectionView *)collectionView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropURL forDraggedItemsAtIndexes:(NSIndexSet *)indexes
{
	NSUInteger index = [indexes firstIndex];
	PXPattern *pattern = [[_patternsController arrangedObjects] objectAtIndex:index];
	
	NSString *dir = [dropURL path];
	NSString *name = @"Pattern.pxpattern";
	
	int i = 2;
	
	while ([[NSFileManager defaultManager] fileExistsAtPath:[dir stringByAppendingPathComponent:name]])
	{
		name = [NSString stringWithFormat:@"Pattern %d.pxpattern", i];
		i++;
	}
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:pattern];
	[data writeToURL:[dropURL URLByAppendingPathComponent:name] atomically:YES];
	
	return [NSArray arrayWithObject:name];
}

- (BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard
{
	[pasteboard declareTypes:[NSArray arrayWithObjects:NSFilesPromisePboardType, nil] owner:self];
	[pasteboard setPropertyList:@[ PXPatternSuffix ] forType:NSFilesPromisePboardType];
	
	return YES;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id<NSDraggingInfo>)draggingInfo index:(NSInteger)index dropOperation:(NSCollectionViewDropOperation)dropOperation
{
	
	NSPasteboard *pboard = [draggingInfo draggingPasteboard];
	NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
	
	for (NSString *path in files) {
		if ([[path pathExtension] isEqualToString:PXPatternSuffix]) {
			PXPattern *pattern = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
			
			if (!pattern || ![pattern isKindOfClass:[PXPattern class]])
				continue;
			
			[self addPattern:pattern];
		}
	}
	
	return YES;
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id<NSDraggingInfo>)draggingInfo proposedIndex:(NSInteger *)proposedDropIndex dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
{
	NSPasteboard *pboard = [draggingInfo draggingPasteboard];
	NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
	
	for (NSString *path in files) {
		if ([[path pathExtension] isEqualToString:PXPatternSuffix])
			return NSDragOperationCopy;
	}
	
	return NSDragOperationNone;
}

@end
