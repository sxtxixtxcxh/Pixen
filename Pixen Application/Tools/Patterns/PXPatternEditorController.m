//
//  PXPatternEditorController.m
//  Pixen
//

#import "PXPatternEditorController.h"

#import "PXPattern.h"
#import "PXPatternEditorView.h"
#import "PXSavedPatternMatrix.h"
#import "PathUtilities.h"
#import "PXPatternCell.h"

@implementation PXPatternEditorController

@synthesize toolName, delegate;

- (NSSize)properContentSize
{
	NSSize viewSize = [view resizeToFitPattern:pattern];
	NSSize contentViewSize = [ (NSView *) [[self window] contentView] frame].size;
	NSSize newSize;
	newSize.width = viewSize.width;
	newSize.height = contentViewSize.height + (viewSize.width - contentViewSize.width);
	return newSize;
}

- (void)awakeFromNib
{
	[view setDelegate:self];
	
	[[self window] setContentAspectRatio:[[self window] contentAspectRatio]];
	[[self window] setContentSize:[self properContentSize]];
	[[self window] setTitle:[NSLocalizedString(@"Pattern Editor: ", @"Pattern Editor:") stringByAppendingString:toolName]];
	
	matrix = [[PXSavedPatternMatrix alloc] initWithWidth:[scrollView contentSize].width patternFile:GetPixenPatternFile()];
	[matrix setDoubleAction:@selector(load:)];
	[matrix setTarget:self];
	[scrollView setDocumentView:matrix];
}

- (void)setPattern:(PXPattern *)pat
{
	[self loadWindow];
	
	[pattern release];
	pattern = [pat copy];
	NSSize patternSize = [pattern size];
	if(patternSize.width < 2) {
		patternSize.width = 2;
	}
	if (patternSize.height < 2) {
		patternSize.height = 2;
	}
	if (!NSEqualSizes([pattern size], patternSize)) {
		[pattern setSize:patternSize];
	}
	if (view) {
		[view setPattern:pattern];
	}
	[[self window] setContentSize:[self properContentSize]];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
	NSSize viewSize = [view resizeToFitWidth:proposedFrameSize.width];
	NSSize newSize;
	newSize.width = viewSize.width;
	newSize.height = NSHeight([sender frame]) + (viewSize.width - NSWidth([sender frame]));
	return newSize;
}

- (IBAction)displayHelp:sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"patterns" inBook:@"Pixen Help"];	
}

- (IBAction)newPattern:sender
{
	PXPattern *newPattern = [[[PXPattern alloc] init] autorelease];
	[newPattern setSize:NSMakeSize(2, 2)];
	[newPattern togglePoint:NSMakePoint(0, 0)];
	[self setPattern:newPattern];
	[delegate patternEditor:self finishedWithPattern:pattern];
}

- (IBAction)save:sender
{
	[matrix addPattern:pattern];
}

- (IBAction)load:sender
{
	[self setPattern:[matrix selectedPattern]];
	[delegate patternEditor:self finishedWithPattern:pattern];
}


- (void)deleteSheetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:contextInfo
{
	if (returnCode == NSAlertFirstButtonReturn)
	{
		[matrix removeSelectedPattern];
	}
}

- (IBAction)deleteSelected:sender
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[[alert addButtonWithTitle:NSLocalizedString(@"Delete", @"DELETE")] setKeyEquivalent:@""];
	NSButton *button = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"CANCEL")];
	[button setKeyEquivalent:@"\r"];
	[alert setMessageText:NSLocalizedString(@"Really delete pattern?", @"PATTERN_DELETE_PROMPT")];
	[alert setInformativeText:NSLocalizedString(@"This operation cannot be undone.", @"PATTERN_DELETE_INFORMATIVE_TEXT")];
	[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:@selector(deleteSheetDidEnd:returnCode:contextInfo:)
						contextInfo:nil];
}

- (id)init
{
	return [super initWithWindowNibName:@"PXPatternEditor"];
}

- (void)patternView:(PXPatternEditorView *)pv changedPattern:(PXPattern *)pat
{
	if (pat != pattern) {
		[self setPattern:pat];
	}
	[delegate patternEditor:self finishedWithPattern:pat];
}

- (PXPattern *)selectedPattern
{
	return [matrix selectedPattern];
}

@end
