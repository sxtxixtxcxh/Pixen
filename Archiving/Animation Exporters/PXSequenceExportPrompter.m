//
//  PXSequenceExportPrompter.m
//  Pixen
//
//  Created by Andy Matuschak on 8/10/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXSequenceExportPrompter.h"
#import "PXCanvasDocument.h"

@interface PXSequenceExportPrompter()
@property (readwrite, copy) NSString *fileTemplate, *fileType;
@property (readwrite, retain) NSSavePanel *savePanel;
@property (readwrite, assign) id delegate;
@property (readwrite, assign) SEL didEndSelector;
@end

@implementation PXSequenceExportPrompter

@synthesize fileTemplate, savePanel, delegate, didEndSelector, view;
@dynamic fileType;

- initWithDocument:(NSDocument *)aDocument
{
	self = [super init];
	self.fileTemplate = [NSString stringWithFormat:@"%@ %%f", [[aDocument displayName] stringByDeletingPathExtension]];
	[NSBundle loadNibNamed:@"PXSequenceExportPrompter" owner:self];
	self.fileType = PixenImageFileType;
	self.savePanel = [NSSavePanel savePanel];
	[savePanel setTitle:@"Choose Target Folder"];
	[savePanel setPrompt:@"Export"];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setAccessoryView:view];
	return self;
}

- (void)dealloc
{
	[savePanel release];
	[fileType release];
	[fileTemplate release];
	[super dealloc];
}

- (NSString *)fileType {
	return fileType;
}

- (void)setFileType:(NSString *)newFT
{
	[fileType release];
	fileType = [newFT retain];
	NSString *newExtension = [[[NSDocumentController sharedDocumentController] fileExtensionsFromType:newFT] objectAtIndex:0];
	NSString *newTemplate = [[self.fileTemplate stringByDeletingPathExtension] stringByAppendingPathExtension:newExtension];
	self.fileTemplate = newTemplate;
}

- (void)panelDidFinish:(NSPanel *)panel 
						returnCode:(int)code 
					 contextInfo:(void *)info
{
	if (code == NSCancelButton) { return; }
	if (NSEqualRanges([self.fileTemplate rangeOfString:@"%f"], NSMakeRange(NSNotFound, 0)))
		self.fileTemplate = [self.fileTemplate stringByAppendingString:@" %f"];
	[self.delegate performSelector:self.didEndSelector withObject:self];
}

- (void)beginSheetModalForWindow:(NSWindow *)parentWindow 
									 modalDelegate:(id)del 
									didEndSelector:(SEL)didEnd
{
	self.delegate = del;
	self.didEndSelector = didEnd;
	[savePanel beginSheetForDirectory:nil 
															 file:nil 
										 modalForWindow:parentWindow 
											modalDelegate:self 
										 didEndSelector:@selector(panelDidFinish:
																							returnCode:
																							contextInfo:) 
												contextInfo:NULL];
}

- (NSArray *)fileTypes
{
	return [PXCanvasDocument writableTypes];
}

@end
