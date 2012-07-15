//
//  PXManagePresetsController.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXManagePresetsController.h"

#import "PXPreset.h"
#import "PXPresetsManager.h"

@implementation PXManagePresetsController

@synthesize tableView = _tableView, canDeletePreset = _canDeletePreset;

- (id)init
{
	self = [super initWithWindowNibName:@"PXManagePresetsWindow"];
	if (self) {
		_presets = [[PXPresetsManager sharedPresetsManager] presets];
	}
	return self;
}

- (void)windowDidLoad
{
	[self presetsChanged:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(presetsChanged:)
												 name:PXPresetsChangedNotificationName
											   object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)presetsChanged:(NSNotification *)notification
{
	[self.tableView reloadData];
	[self tableViewSelectionDidChange:nil];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [_presets count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [[_presets objectAtIndex:row] name];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	PXPreset *preset = [_presets objectAtIndex:row];
	preset.name = object;
	
	[[PXPresetsManager sharedPresetsManager] persistPresets];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	self.canDeletePreset = ([self.tableView selectedRow] != -1);
}

- (IBAction)deletePreset:(id)sender
{
	if ([self.tableView selectedRow] != -1) {
		PXPreset *preset = [_presets objectAtIndex:[self.tableView selectedRow]];
		
		[[PXPresetsManager sharedPresetsManager] removePresetWithName:[preset name]];
	}
}

- (IBAction)done:(id)sender
{
	[self close];
	[NSApp endSheet:[self window]];
}

@end
