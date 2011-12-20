//
//  PXSequenceExportViewController.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXSequenceExportViewController : NSViewController

@property (nonatomic, assign) IBOutlet NSArrayController *typesController;

@property (nonatomic, copy) NSString *fileTemplate;
@property (nonatomic, readonly) NSString *selectedUTI;

@end
