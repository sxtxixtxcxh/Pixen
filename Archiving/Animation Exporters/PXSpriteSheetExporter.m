//
//  PXSpriteSheetExporter.m
//  Pixen
//
//  Created by Ian Henderson on 12.08.05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXSpriteSheetExporter.h"
#import "PXDocumentController.h"
#import "PXAnimationDocument.h"
#import "PXAnimation.h"

@implementation PXSpriteSheetExporter

- (id)init
{
	if ( ! (self = [super initWithWindowNibName:@"PXSpriteSheetExporter"]))
		return nil;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentsChanged:) name:PXDocumentDidCloseNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentsChanged:) name:PXDocumentOpenedNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentsChanged:) name:PXDocumentChangedDisplayNameNotificationName object:nil];
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)recacheDocumentRepresentations
{
	NSArray *animationDocuments = [[PXDocumentController sharedDocumentController] animationDocuments];
	
	NSArray *oldRepresentations = documentRepresentations;
	documentRepresentations = [[NSMutableArray alloc] init];
	
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
		
		[ (NSMutableArray *) documentRepresentations addObject:dict];
	}
	
	[oldRepresentations release];
}

- (void)documentsChanged:(NSNotification *)notification
{
	PXAnimationDocument *doc = [notification object];
	
	if ([doc isKindOfClass:[PXAnimationDocument class]]) {
		[self willChangeValueForKey:@"documentRepresentations"];
		[self recacheDocumentRepresentations];
		[self didChangeValueForKey:@"documentRepresentations"];
		
		[self updatePreview:nil];
	}
}

+ (id)sharedSpriteSheetExporter
{
	static PXSpriteSheetExporter *sharedSpriteSheetExporter = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedSpriteSheetExporter = [[self alloc] init];
	});
	
	return sharedSpriteSheetExporter;
}

- (NSArray *)documentRepresentations
{
	if (!documentRepresentations) {
		[self recacheDocumentRepresentations];
	}
	
	return documentRepresentations;
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
	
	for (NSDictionary *docRep in documentRepresentations)
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
		[sheetImageView setImage:[NSImage imageNamed:@"Pixen"]];
	}
}

- (void)windowDidLoad
{
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
	[savePanel setRequiredFileType: (NSString *) kUTTypePNG];
	
	[savePanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
		
		[self savePanelDidEnd:savePanel returnCode:result];
		
	}];
}

@end
