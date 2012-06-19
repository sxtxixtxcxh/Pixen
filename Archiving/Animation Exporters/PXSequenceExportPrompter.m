//
//  PXSequenceExportPrompter.m
//  Pixen
//
//  Created by Andy Matuschak on 8/10/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import "PXSequenceExportPrompter.h"

#import "PXCanvasDocument.h"
#import "PXSequenceExportViewController.h"

@implementation PXSequenceExportPrompter

@dynamic fileTemplate, selectedUTI;
@synthesize savePanel;

- (id)initWithDocument:(NSDocument *)aDocument
{
	self = [super init];
	
	vc = [[PXSequenceExportViewController alloc] init];
	vc.fileTemplate = [NSString stringWithFormat:@"%@ %%f", [[aDocument displayName] stringByDeletingPathExtension]];
	
	savePanel = [[NSOpenPanel openPanel] retain];
	[savePanel setTitle:@"Choose Target Folder"];
	[savePanel setPrompt:@"Export"];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setCanChooseDirectories:YES];
	[savePanel setCanChooseFiles:NO];
	[savePanel setAccessoryView:vc.view];
	
	return self;
}

- (void)dealloc
{
	[savePanel release];
	[vc release];
	[super dealloc];
}

- (void)beginSheetModalForWindow:(NSWindow *)parentWindow
				   modalDelegate:(id)delegate
				  didEndSelector:(SEL)didEndSelector
{
	[savePanel beginSheetModalForWindow:parentWindow
					  completionHandler:^(NSInteger result) {
						  
						  if (result == NSFileHandlingPanelCancelButton)
							  return;
						  
						  if (NSEqualRanges([vc.fileTemplate rangeOfString:@"%f"], NSMakeRange(NSNotFound, 0)))
							  vc.fileTemplate = [vc.fileTemplate stringByAppendingString:@" %f"];
						  
						  [delegate performSelector:didEndSelector withObject:self];
						  
					  }];
}

- (NSString *)fileTemplate
{
	return vc.fileTemplate;
}

- (NSString *)selectedUTI
{
	return [vc selectedUTI];
}

@end
