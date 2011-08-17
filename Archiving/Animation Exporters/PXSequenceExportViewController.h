//
//  PXSequenceExportViewController.h
//  Pixen
//
//  Created by Matt Rajca on 8/17/11.
//  Copyright 2011 Matt Rajca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXSequenceExportViewController : NSViewController {
  @private
	NSArrayController *_typesController;
	NSMutableArray *_fileTypes;
	NSString *_fileTemplate;
}

@property (nonatomic, assign) IBOutlet NSArrayController *typesController;

@property (nonatomic, copy) NSString *fileTemplate;
@property (nonatomic, readonly) NSString *selectedUTI;

- (IBAction)changedSelection:(id)sender;

@end
