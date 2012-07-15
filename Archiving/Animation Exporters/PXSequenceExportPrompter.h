//
//  PXSequenceExportPrompter.h
//  Pixen
//
//  Created by Andy Matuschak on 8/10/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PXSequenceExportViewController;

@interface PXSequenceExportPrompter : NSObject
{
  @private
	PXSequenceExportViewController *vc;
	NSOpenPanel *savePanel;
}

@property (nonatomic, strong, readonly) NSOpenPanel *savePanel;
@property (nonatomic, readonly) NSString *fileTemplate, *selectedUTI;

- (id)initWithDocument:(NSDocument *)document;

- (void)beginSheetModalForWindow:(NSWindow *)parentWindow
				   modalDelegate:(id)delegate
				  didEndSelector:(SEL)didEndSelector;

@end
