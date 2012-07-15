//
//  PXManagePresetsController.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

@interface PXManagePresetsController : NSWindowController < NSTableViewDataSource, NSTableViewDelegate >
{
  @private
	NSArray *_presets;
	BOOL _canDeletePreset;
}

@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@property (nonatomic, assign) BOOL canDeletePreset;

- (IBAction)deletePreset:(id)sender;
- (IBAction)done:(id)sender;

- (void)presetsChanged:(NSNotification *)notification;

@end
