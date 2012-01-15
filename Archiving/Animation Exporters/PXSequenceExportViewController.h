//
//  PXSequenceExportViewController.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXSequenceExportViewController : NSViewController
{
  @private
    NSArrayController *_typesController;
    NSString *_fileTemplate;
}

@property (nonatomic, assign) IBOutlet NSArrayController *typesController;

@property (nonatomic, copy) NSString *fileTemplate;
@property (nonatomic, readonly) NSString *selectedUTI;

@end
