//
//  PXPatternEditorController.m
//  Pixen
//

#import "PXPatternEditorController.h"

#import "PXPattern.h"
#import "PXPatternEditorView.h"
#import "PathUtilities.h"
#import "SBCenteringClipView.h"

@implementation PXPatternEditorController

@synthesize toolName, patternFileName, delegate;

/*
- (NSSize)properContentSize
{
	NSSize viewSize = [view resizeToFitPattern:pattern];
	NSSize contentViewSize = [ (NSView *) [[self window] contentView] frame].size;
	NSSize newSize;
	newSize.width = viewSize.width;
	newSize.height = contentViewSize.height + (viewSize.width - contentViewSize.width);
	return newSize;
}*/

- (void)awakeFromNib
{
	[editorView setDelegate:self];
	
	id clip = [[[SBCenteringClipView alloc] initWithFrame:[[scrollView contentView] frame]] autorelease];
	[clip setBackgroundColor:[NSColor lightGrayColor]];
	[clip setCopiesOnScroll:NO];
	
	[(NSScrollView *)scrollView setContentView:clip];
	[scrollView setDocumentView:editorView];
	
	//[[self window] setTitle:[NSLocalizedString(@"Pattern Editor: ", @"Pattern Editor:") stringByAppendingString:toolName]];
}

- (void)setPattern:(PXPattern *)pat
{
	[self loadWindow];
	
	[_pattern release];
	_pattern = [pat copy];
	
	NSSize patternSize = [_pattern size];
	if(patternSize.width < 2) {
		patternSize.width = 2;
	}
	if (patternSize.height < 2) {
		patternSize.height = 2;
	}
	if (!NSEqualSizes([_pattern size], patternSize)) {
		[_pattern setSize:patternSize];
	}
	if (editorView) {
		[editorView setFrame:NSMakeRect(0, 0, patternSize.width * 32, patternSize.height * 32)];
		[editorView setPattern:_pattern];
	}
}

- (IBAction)displayHelp:(id)sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"patterns" inBook:@"Pixen Help"];
}

- (IBAction)newPattern:(id)sender
{
	[self addPattern:[[_pattern copy] autorelease]];
	
	// [delegate patternEditor:self finishedWithPattern:newPattern];
}

/*
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
 */

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
	self = [super initWithWindowNibName:@"PXPatternEditor"];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(patternsChanged:)
												 name:PXPatternsChangedNotificationName
											   object:nil];
	[self setPatternFileName:GetPixenPatternFile()];
	return self;
}

- (void)windowDidLoad
{
	[self reloadPatterns];
}

- (void)patternView:(PXPatternEditorView *)pv changedPattern:(PXPattern *)pat
{
	if (pat != _pattern) {
		[self setPattern:pat];
	}
	[delegate patternEditor:self finishedWithPattern:pat];
}

- (void)reloadPatterns
{
	BOOL isDirectory;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath:patternFileName isDirectory:&isDirectory] || isDirectory) {
		return;
	}
	
	[patternsController removeObjects:[patternsController arrangedObjects]];
	
	NSArray *p = [NSKeyedUnarchiver unarchiveObjectWithFile:patternFileName];
	
	if (p)
		[patternsController addObjects:p];
}

/*
 - (void)keyDown:(NSEvent *)event
 {
 if ([[event characters] isEqualToString: @"\177"] || ([[event characters] characterAtIndex:0] == NSDeleteFunctionKey))
 {
 [self removePattern:[self selectedPattern]];
 }
 }
 */

- (void)patternsChanged:(NSNotification *)notification
{
	
}

- (void)addPattern:(PXPattern *)pattern
{
	[patternsController addObject:pattern];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternsChangedNotificationName
														object:self
													  userInfo:nil];
	
	[NSKeyedArchiver archiveRootObject:[patternsController arrangedObjects] toFile:patternFileName];
}

- (void)removePattern:(PXPattern *)pattern
{
	[patternsController removeObject:pattern];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternsChangedNotificationName
														object:self
													  userInfo:nil];
	
	[NSKeyedArchiver archiveRootObject:[patternsController arrangedObjects] toFile:patternFileName];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[patternFileName release];
	[super dealloc];
}

//- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
//{
//	return NSDragOperationCopy;
//}

/*
 
 - (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
 {
 if (NSEqualPoints(dragOrigin, NSZeroPoint))
 dragOrigin = currentPoint;
 
 float xOffset = currentPoint.x - dragOrigin.x, yOffset = currentPoint.y - dragOrigin.y;
 float distance = sqrt(xOffset*xOffset + yOffset*yOffset);
 
 if (distance <= 5)
 return YES;
 
 NSImage *image = [[NSImage alloc] initWithSize:lastFrame.size];
 [image lockFocus];
 NSRect bounds = lastFrame;
 bounds.origin = NSZeroPoint;
 [self drawWithCellBounds:bounds flipText:NO];
 [image unlockFocus];
 NSImage *translucentImage = [[NSImage alloc] initWithSize:lastFrame.size];
 [translucentImage lockFocus];
 [image compositeToPoint:NSZeroPoint operation:NSCompositeCopy fraction:.66];
 [image release];
 
 [translucentImage unlockFocus];
 
 NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
 [pasteboard declareTypes:[NSArray arrayWithObjects:PXPatternPboardType,
 NSFilenamesPboardType,
 nil] owner:nil];
 [pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:pattern] forType:PXPatternPboardType];
 
 NSString *tempFile = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"Pattern"] stringByAppendingPathExtension:PXPatternSuffix];
 [NSKeyedArchiver archiveRootObject:pattern toFile:tempFile];
 [pasteboard setPropertyList:[NSArray arrayWithObject:tempFile] forType:NSFilenamesPboardType];
 
 NSPoint origin = lastFrame.origin;
 origin.y += NSHeight(lastFrame);
 [controlView dragImage:translucentImage at:origin offset:NSMakeSize(xOffset, yOffset) event:dragEvent pasteboard:pasteboard source:delegate slideBack:NO];
 [translucentImage release];
 
 dragOrigin = NSZeroPoint;
 [self setState:NSOnState];
 return YES;
 }
 */

@end
