//
//  PXSequenceExportViewController.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXSequenceExportViewController.h"

#import "PXCanvasDocument.h"
#import "UTType+NSString.h"

@implementation PXSequenceExportViewController

@synthesize typesController = _typesController, fileTemplate = _fileTemplate;
@dynamic selectedUTI;

- (id)init
{
	return [super initWithNibName:@"PXSequenceExportView" bundle:nil];
}

- (void)dealloc
{
	[_typesController removeObserver:self forKeyPath:@"selectionIndex"];
	[_fileTemplate release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	for (NSString *type in [PXCanvasDocument writableTypes]) {
		if (UTTypeEqualNSString(type, PixenImageFileTypeOld) ||
			UTTypeEqualNSString(type, PixenAnimationFileType) ||
			UTTypeEqualNSString(type, PixenAnimationFileTypeOld)) {
			
			continue;
		}
		
		NSString *displayName = (NSString *) UTTypeCopyDescription( (__bridge CFStringRef) type);
		
		if (displayName) {
			[_typesController addObject:[NSDictionary dictionaryWithObjectsAndKeys:
										 displayName, @"name", type, @"uti", nil]];
			[displayName release];
		}
	}
	
	[_typesController addObserver:self
					   forKeyPath:@"selectionIndex"
						  options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
						  context:NULL];
	
	[_typesController setSelectionIndex:0];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (![keyPath isEqualToString:@"selectionIndex"])
		return;
	
	NSString *uti = [self selectedUTI];
	id ext = nil;
	
	if ([uti rangeOfString:@"Pixen"].location != NSNotFound) {
		ext = @"pxi";
	}
	else {
		NSDictionary *dictionary = (NSDictionary *) UTTypeCopyDeclaration( (__bridge CFStringRef) uti);
		ext = [[dictionary valueForKey:(NSString *) kUTTypeTagSpecificationKey] valueForKey:(NSString *) kUTTagClassFilenameExtension];
		
		if ([ext isKindOfClass:[NSArray class]])
			ext = [ext objectAtIndex:0];
		
		[dictionary release];
	}
	
	self.fileTemplate = [[_fileTemplate stringByDeletingPathExtension] stringByAppendingPathExtension:ext];
}

- (NSString *)selectedUTI
{
	NSArray *selectedUTIs = [_typesController selectedObjects];
	
	if (![selectedUTIs count])
		return nil;
	
	return [[selectedUTIs objectAtIndex:0] valueForKey:@"uti"];
}

@end
