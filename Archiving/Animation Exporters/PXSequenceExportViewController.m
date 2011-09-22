//
//  PXSequenceExportViewController.m
//  Pixen
//
//  Created by Matt Rajca on 8/17/11.
//  Copyright 2011 Matt Rajca. All rights reserved.
//

#import "PXSequenceExportViewController.h"

#import "PXCanvasDocument.h"
#import "UTType+NSString.h"

@implementation PXSequenceExportViewController

@synthesize typesController = _typesController, fileTemplate = _fileTemplate;
@dynamic selectedUTI;

- (id)init
{
	self = [super initWithNibName:@"PXSequenceExportView" bundle:nil];
	return self;
}

- (void)dealloc
{
	[_fileTypes release];
	[_fileTemplate release];
	[super dealloc];
}

- (NSArray *)fileTypes
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		_fileTypes = [[NSMutableArray alloc] init];
		
		for (NSString *type in [PXCanvasDocument writableTypes]) {
			if (UTTypeEqualNSString(type, PixenImageFileTypeOld) ||
				UTTypeEqualNSString(type, PixenAnimationFileType) ||
				UTTypeEqualNSString(type, PixenAnimationFileTypeOld)) {
				
				continue;
			}
			
			NSString *displayName = (NSString *) UTTypeCopyDescription((__bridge CFStringRef)type);
			
			if (displayName) {
				[_fileTypes addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									   displayName, @"name", type, @"uti", nil]];
				[displayName release];
			}
		}
		
		[self changedSelection:nil];
		
	});
	
	return _fileTypes;
}

- (IBAction)changedSelection:(id)sender
{
	[_typesController setSelectionIndex:[sender indexOfSelectedItem]];
	
	NSDictionary *dictionary = (NSDictionary *) UTTypeCopyDeclaration((__bridge CFStringRef)[self selectedUTI]);
	id ext = [[dictionary valueForKey:(NSString *)kUTTypeTagSpecificationKey] valueForKey:(NSString *)kUTTagClassFilenameExtension];
	
	if ([ext isKindOfClass:[NSArray class]])
		ext = [ext objectAtIndex:0];
	
	NSString *template = [[_fileTemplate stringByDeletingPathExtension] stringByAppendingPathExtension:ext];
	self.fileTemplate = template;
	
	[dictionary release];
}

- (NSString *)selectedUTI
{
	return [[_fileTypes objectAtIndex:[_typesController selectionIndex]] valueForKey:@"uti"];
}

@end
