//
//  PXSpriteSheetExporter.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXSpriteSheetExporter.h"

#import "PXAnimation.h"
#import "PXAnimationDocument.h"
#import "PXDocumentController.h"

@implementation PXSpriteSheetExporter

@synthesize sheetImageView, documentRepresentationsController;

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
	[super dealloc];
}

- (NSDictionary *)findRepresentationForDocument:(PXAnimationDocument *)document
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
	
	NSArray *animationDocuments = [[PXDocumentController sharedDocumentController] animationDocuments];
	
	for (PXAnimationDocument *doc in animationDocuments)
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
	
	[oldRepresentations release];
}

- (void)documentsChanged:(NSNotification *)notification
{
	PXAnimationDocument *doc = [notification object];
	
	if ([doc isKindOfClass:[PXAnimationDocument class]]) {
		[self recacheDocumentRepresentations];
		[self updatePreview:nil];
	}
}

- (NSColor *)backgroundColor
{
	return [NSColor whiteColor];
}

- (NSImage *)spriteSheetImage
{
	int interAnimationMargin = 0;
	int interCelMargin = 0;
	int padding = 0;
	
	NSMutableArray *animationSheets = [NSMutableArray array];
	NSSize sheetSize = NSMakeSize(padding*2, padding*2);
	
	for (NSDictionary *docRep in [documentRepresentationsController arrangedObjects])
	{
		PXAnimation *animation = [[docRep objectForKey:@"document"] animation];
		
		if ([[docRep objectForKey:@"included"] boolValue]) {
			NSImage *spriteSheetRow = [animation spriteSheetWithCelMargin:interCelMargin];
			
			if ([spriteSheetRow size].width > sheetSize.width) {
				sheetSize.width = [spriteSheetRow size].width;
			}
			
			sheetSize.height += [spriteSheetRow size].height + interAnimationMargin;
			
			[animationSheets addObject:spriteSheetRow];
		}
	}
	
	if (NSEqualSizes(sheetSize, NSMakeSize(padding*2, padding*2)))
		return nil;
	
	sheetSize.height -= interAnimationMargin;
	
	NSImage *spriteSheet = [[[NSImage alloc] initWithSize:sheetSize] autorelease];
	
	[spriteSheet lockFocus];
	
	[[NSColor clearColor] set];
	NSRectFill(NSMakeRect(0.0f,0.0f,sheetSize.width,sheetSize.height));
	
	NSPoint currentPoint = NSMakePoint(padding, 0.0f);
	
	for (NSImage *row in animationSheets)
	{
		[row compositeToPoint:currentPoint operation:NSCompositeSourceOver];
		
		currentPoint.y += [row size].height;
		currentPoint.y += interAnimationMargin;
	}
	
	[spriteSheet unlockFocus];
	
	return spriteSheet;
}

- (IBAction)updatePreview:(id)sender
{
	NSImage *img = [self spriteSheetImage];
	
	if (img) {
		[sheetImageView setImage:[self spriteSheetImage]];
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
	
	NSImage *spriteSheet = [self spriteSheetImage];
	NSRect spriteSheetRect = { NSZeroPoint, [spriteSheet size] };
	
	[spriteSheet lockFocus];
	NSBitmapImageRep *bitmap = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:spriteSheetRect] autorelease];
	[spriteSheet unlockFocus];
	
	[[bitmap representationUsingType:NSPNGFileType properties:nil] writeToURL:[sheet URL]
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

@end
