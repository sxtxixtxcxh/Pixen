//
//  PXSpriteSheetExporter.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXSpriteSheetExporter.h"

#import "NSImage+Reps.h"
#import "PXAnimation.h"
#import "PXAnimationDocument.h"
#import "PXCanvas_ImportingExporting.h"
#import "PXCanvasDocument.h"
#import "PXDocumentController.h"

@implementation PXSpriteSheetExporter

@synthesize sheetImageView, documentRepresentationsController;

static NSString *const kSpriteSheetEntry = @"SpriteSheetEntry";

+ (id)sharedSpriteSheetExporter
{
	static PXSpriteSheetExporter *sharedSpriteSheetExporter = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedSpriteSheetExporter = [[self alloc] init];
	});
	
	return sharedSpriteSheetExporter;
}

- (id)init
{
	self = [super initWithWindowNibName:@"PXSpriteSheetExporter"];
	if (self) {
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		
		[center addObserver:self selector:@selector(documentsChanged:) name:PXDocumentOpenedNotificationName object:nil];
		[center addObserver:self selector:@selector(documentsChanged:) name:PXDocumentDidCloseNotificationName object:nil];
		[center addObserver:self selector:@selector(documentsChanged:) name:PXDocumentChangedDisplayNameNotificationName object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSDictionary *)findRepresentationForDocument:(PXDocument *)document
{
	for (NSDictionary *rep in [documentRepresentationsController arrangedObjects])
	{
		if ([rep objectForKey:@"document"] == document)
			return rep;
	}
	
	return nil;
}

- (void)recacheDocumentRepresentations
{
	NSArray *oldRepresentations = [[documentRepresentationsController arrangedObjects] copy];
	[documentRepresentationsController removeObjects:oldRepresentations];
	
	NSArray *documents = [[PXDocumentController sharedDocumentController] documents];
	
	for (PXDocument *doc in documents)
	{
		BOOL included = NO;
		
		for (NSDictionary *oldRep in oldRepresentations)
		{
			if ([oldRep objectForKey:@"document"] == doc) {
				included = [[oldRep objectForKey:@"included"] boolValue];
				break;
			}
		}
		
		NSDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
							  doc, @"document", [doc displayName], @"displayName",
							  [NSNumber numberWithBool:included], @"included", nil];
		
		[documentRepresentationsController addObject:dict];
	}
}

- (void)documentsChanged:(NSNotification *)notification
{
	PXDocument *doc = [notification object];
	
	if ([doc isKindOfClass:[PXDocument class]]) {
		[self recacheDocumentRepresentations];
		[self updatePreview:nil];
	}
}

- (NSColor *)backgroundColor
{
	return [NSColor whiteColor];
}

- (NSBitmapImageRep *)spriteSheetImageRep
{
	int interAnimationMargin = 0;
	int interCelMargin = 0;
	int padding = 0;
	
	NSMutableArray *animationSheets = [NSMutableArray array];
	NSSize sheetSize = NSMakeSize(padding*2, padding*2);
	
	for (NSDictionary *docRep in [documentRepresentationsController arrangedObjects])
	{
		PXDocument *document = [docRep objectForKey:@"document"];
		
		if ([document isKindOfClass:[PXAnimationDocument class]]) {
			if ([[docRep objectForKey:@"included"] boolValue]) {
				PXAnimation *animation = [ (PXAnimationDocument *) document animation];
				
				NSBitmapImageRep *spriteSheetRow = [animation spriteSheetWithCelMargin:interCelMargin];
				
				if ([spriteSheetRow size].width > sheetSize.width) {
					sheetSize.width = [spriteSheetRow size].width;
				}
				
				sheetSize.height += [spriteSheetRow size].height + interAnimationMargin;
				
				[animationSheets addObject:spriteSheetRow];
			}
		}
		else if ([document isKindOfClass:[PXCanvasDocument class]]) {
			if ([[docRep objectForKey:@"included"] boolValue]) {
				PXCanvas *canvas = [ (PXCanvasDocument *) document canvas];
				
				NSBitmapImageRep *spriteSheetRow = [canvas imageRep];
				
				if ([spriteSheetRow size].width > sheetSize.width) {
					sheetSize.width = [spriteSheetRow size].width;
				}
				
				sheetSize.height += [spriteSheetRow size].height + interAnimationMargin;
				
				[animationSheets addObject:spriteSheetRow];
			}
		}
	}
	
	if (NSEqualSizes(sheetSize, NSMakeSize(padding*2, padding*2)))
		return nil;
	
	sheetSize.height -= interAnimationMargin;
	
	NSBitmapImageRep *spriteSheet = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
																			pixelsWide:sheetSize.width
																			pixelsHigh:sheetSize.height
																		 bitsPerSample:8
																	   samplesPerPixel:4
																			  hasAlpha:YES
																			  isPlanar:NO
																		colorSpaceName:NSCalibratedRGBColorSpace
																		   bytesPerRow:sheetSize.width * 4
																		  bitsPerPixel:32];
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:spriteSheet]];
	
	[[NSColor clearColor] set];
	NSRectFill(NSMakeRect(0.0f,0.0f,sheetSize.width,sheetSize.height));
	
	NSPoint currentPoint = NSMakePoint(padding, 0.0f);
	
	for (NSBitmapImageRep *row in animationSheets)
	{
		[row drawInRect:NSMakeRect(currentPoint.x, currentPoint.y, [row size].width, [row size].height)
			   fromRect:NSZeroRect
			  operation:NSCompositeSourceOver
			   fraction:1.0f
		 respectFlipped:NO
				  hints:nil];
		
		currentPoint.y += [row size].height;
		currentPoint.y += interAnimationMargin;
	}
	
	[NSGraphicsContext restoreGraphicsState];
	
	return spriteSheet;
}

- (IBAction)updatePreview:(id)sender
{
	NSBitmapImageRep *imageRep = [self spriteSheetImageRep];
	
	if (imageRep) {
		NSImage *img = [NSImage imageWithBitmapImageRep:imageRep];
		[sheetImageView setImage:img];
	}
	else {
		[sheetImageView setImage:[NSImage imageNamed:@"Pixen128"]];
	}
}

- (void)windowDidLoad
{
	[self recacheDocumentRepresentations];
}

- (void)showWindow:(id)sender
{
	[super showWindow:sender];
	[self updatePreview:self];
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(NSInteger)returnCode
{
	if (returnCode == NSFileHandlingPanelCancelButton) {
		closeOnEndSheet = NO;
	} else {
		closeOnEndSheet = YES;
	}
	
	NSBitmapImageRep *spriteSheet = [self spriteSheetImageRep];
	
	[[spriteSheet representationUsingType:NSPNGFileType properties:nil] writeToURL:[sheet URL]
																		atomically:YES];
}

- (void)windowDidEndSheet:(NSNotification *)notification
{
	if (closeOnEndSheet) {
		[self close];
	}
}

- (IBAction)export:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setExtensionHidden:NO];
	[savePanel setCanSelectHiddenExtension:NO];
	[savePanel setTitle:@"Save Sprite Sheet"];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject: (NSString *) kUTTypePNG]];
	
	[savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
		
		[self savePanelDidEnd:savePanel returnCode:result];
		
	}];
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
	[tableView registerForDraggedTypes:@[ kSpriteSheetEntry ]];
	
	NSData *indexSetData = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	[pboard declareTypes:[NSArray arrayWithObject:kSpriteSheetEntry] owner:self];
	[pboard setData:indexSetData forType:kSpriteSheetEntry];
	
	return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
	if (dropOperation == NSTableViewDropOn || row == [[documentRepresentationsController arrangedObjects] count])
		return NSDragOperationNone;
	
	return NSDragOperationGeneric;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
	NSPasteboard *pboard = [info draggingPasteboard];
	NSData *rowData = [pboard dataForType:kSpriteSheetEntry];
	NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	NSInteger dragRow = [rowIndexes firstIndex];
	
	id dragObject = [documentRepresentationsController arrangedObjects][dragRow];
	[documentRepresentationsController removeObjectAtArrangedObjectIndex:dragRow];
	[documentRepresentationsController insertObject:dragObject atArrangedObjectIndex:row];
	
	[self updatePreview:nil];
	
	return YES;
}

@end
