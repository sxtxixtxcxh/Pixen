//
//  PXManagePresetsController.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

@interface PXManagePresetsController : NSWindowController < NSTableViewDataSource, NSTableViewDelegate >

@property (nonatomic, retain) IBOutlet NSTableView *tableView;

@property (nonatomic, assign) BOOL canDeletePreset;

- (IBAction)deletePreset:(id)sender;
- (IBAction)done:(id)sender;

- (void)presetsChanged:(NSNotification *)notification;

@end
