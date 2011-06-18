//
//  PXSequenceExportPrompter.h
//  Pixen
//
//  Created by Andy Matuschak on 8/10/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PXSequenceExportPrompter : NSObject {
	NSSavePanel *savePanel;
	NSString *fileTemplate;
	NSString *fileType;
	IBOutlet NSView *view;
	
	id delegate;
	SEL didEndSelector;
}
@property (readonly, copy) NSString *fileTemplate, *fileType;
@property (readonly, retain) NSSavePanel *savePanel;
@property (readwrite, retain) NSView *view;

- (id)initWithDocument:(NSDocument *)document;
- (void)beginSheetModalForWindow:(NSWindow *)parentWindow 
									 modalDelegate:(id)delegate 
									didEndSelector:(SEL)didEndSelector;
- (NSSavePanel *)savePanel;
- (NSString *)fileTemplate;
- (void)setFileType:(NSString *)type;

@end
