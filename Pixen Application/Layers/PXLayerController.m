//
//  PXLayerController.m
//  Pixen
//

#import "PXLayerController.h"

#import "NSImage+Reps.h"
#import "PXCanvas_CopyPaste.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Selection.h"
#import "PXCanvasDocument.h"
#import "PXLayer.h"
#import "PXLayerCellView.h"
#import "PXLayerRowView.h"
#import "PXNotifications.h"

@interface PXLayerController ()

- (void)updateRemoveButtonState;

- (void)propagateLayerAtIndex:(NSUInteger)index;

- (NSUInteger)invertLayerIndex:(NSUInteger)index;

- (void)highlightLayerAtIndex:(NSUInteger)index;

@end


@implementation PXLayerController

@synthesize tableView = _tableView, removeButton = _removeButton;
@synthesize canvas = _canvas;

- (id)init
{
	return [super initWithNibName:@"PXLayerController" bundle:nil];
}

- (id)initWithCanvas:(PXCanvas *)aCanvas
{
	self = [self init];
	if (self) {
		[self setCanvas:aCanvas];
	}
	return self;
}

- (void)dealloc
{
	[[self class] cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
	NSArray *types = [NSArray arrayWithObjects:PXLayerRowPboardType, NSFilenamesPboardType, nil];
	
	[self.tableView registerForDraggedTypes:types];
	[self.tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
	[self.tableView setDraggingSourceOperationMask:NSDragOperationGeneric forLocal:NO];
	[self.tableView setMenu:[self setupMenu]];
}

#pragma mark -
#pragma mark UI

- (void)updateRemoveButtonState
{
	[_removeButton setEnabled:([[_canvas layers] count] > 1)];
}

#pragma mark -
#pragma mark Helper

- (void)setCanvas:(PXCanvas *)aCanvas
{
	if (_canvas != aCanvas)
	{
		NSString *layerName = [[_canvas activeLayer] name];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc removeObserver:self];
		
		_canvas = aCanvas;
		
		if (_canvas)
		{
			[self reloadData];
			
			[nc addObserver:self
				   selector:@selector(selectionDidChange:)
					   name:PXCanvasLayerSelectionDidChangeNotificationName
					 object:_canvas];
			
			[nc addObserver:self
				   selector:@selector(addedLayer:)
					   name:PXCanvasAddedLayerNotificationName
					 object:_canvas];
			
			[nc addObserver:self
				   selector:@selector(removedLayer:)
					   name:PXCanvasRemovedLayerNotificationName
					 object:_canvas];
			
			[nc addObserver:self
				   selector:@selector(movedLayer:)
					   name:PXCanvasMovedLayerNotificationName
					 object:_canvas];
			
			[nc addObserver:self
				   selector:@selector(setLayers:)
					   name:PXCanvasSetLayersNotificationName
					 object:_canvas];
			
			[nc addObserver:self
				   selector:@selector(updatePreview:)
					   name:PXCanvasChangedNotificationName
					 object:_canvas];
			
			[nc addObserver:self
				   selector:@selector(tableViewSelectionDidChange:)
					   name:NSTableViewSelectionDidChangeNotification
					 object:self.tableView];
			
			if (layerName) {
				PXLayer *layer = [_canvas layerNamed:layerName];
				
				if (layer) {
					dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0);
					dispatch_after(popTime, dispatch_get_main_queue(), ^{
						
						[_canvas activateLayer:layer];
						
					});
				}
			}
		}
	}
}

#pragma mark -
#pragma mark Preview

- (void)updatePreviewReal
{
	[self.tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
		
		PXLayerCellView *cellView = [rowView viewAtColumn:0];
		PXLayer *layer = [cellView objectValue];
		
		cellView.imageView.image = [layer quickImage];
		
	}];
}

- (void)updatePreview:(NSNotification *)notification
{
	[[self class] cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(updatePreviewReal) withObject:nil afterDelay:0.5];
}

#pragma mark -
#pragma mark Data

- (void)reloadData
{
	[self.tableView reloadData];
	
	[self selectLayerAtIndex:0];
	[self updateRemoveButtonState];
}

- (void)setLayers:(NSNotification *)notification
{
	[self reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[self.canvas layers] count];
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
	PXLayerRowView *rowView = [[PXLayerRowView alloc] initWithFrame:NSZeroRect];
	
	return rowView;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSTableCellView *cell = [tableView makeViewWithIdentifier:@"LayerCell" owner:self];
	cell.imageView.image = nil;
	
	return cell;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
			row:(NSInteger)row
{
	return [[self.canvas layers] objectAtIndex:[self invertLayerIndex:row]];
}

- (NSUInteger)invertLayerIndex:(NSUInteger)index
{
	NSInteger newIndex = [[_canvas layers] count] - index - 1;
	
	if (newIndex < 0)
		return NSNotFound;
	
	return newIndex;
}

#pragma mark -
#pragma mark Menu

- (NSString *)degreeString
{
	UniChar degree[] = { 0x00B0 };
	return [NSString stringWithCharacters:degree length:1];
}

- (NSMenu *)setupMenu
{
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@"CM"];
	
	NSMenuItem *item;
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Delete", @"Delete")];
	[item setAction:@selector(removeLayer:)];
	[item setTarget:self];
	[menu addItem:item];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Duplicate", @"Duplicate")];
	[item setAction:@selector(duplicateSelectedLayer)];
	[item setTarget:self];
	[menu addItem:item];
    
    item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Toggle Visibility", @"Toggle Visibility")];
	[item setAction:@selector(toggleVisibility)];
	[item setTarget:self];
	[menu addItem:item];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Merge Down", @"Merge Down")];
	[item setAction:@selector(mergeDownSelectedLayer)];
	[item setTarget:self];
	[menu addItem:item];
	
	[menu addItem:[NSMenuItem separatorItem]];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Cut", @"Cut")];
	[item setAction:@selector(cutSelectedLayer)];
	[item setTarget:self];
	[menu addItem:item];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Copy", @"Copy")];
	[item setAction:@selector(copySelectedLayer)];
	[item setTarget:self];
	[menu addItem:item];

	
	NSMenu *subMenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Transform Layer", @"Transform Layer")];
	
	NSMenuItem *subMenuItem = [[NSMenuItem alloc] init];
	[subMenuItem setTitle:NSLocalizedString(@"Transform Layer", @"Transform Layer")];
	
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItem:subMenuItem];
	
	[menu setSubmenu:subMenu forItem:subMenuItem];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Flip Horizontally", @"Flip Horizontally")];
	[item setAction:@selector(flipLayerHorizontally)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Flip Vertically", @"Flip Vertically")];
	[item setAction:@selector(flipLayerVertically)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	[subMenu addItem:[NSMenuItem separatorItem]];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rotate 90%@ Left", @"Rotate 90%@ Left"), [self degreeString]]];
	[item setAction:@selector(rotateLayerCounterclockwise)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rotate 90%@ Right", @"Rotate 90%@ Right"), [self degreeString]]];
	[item setAction:@selector(rotateLayerClockwise)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rotate 180%@", @"Rotate 180%@"), [self degreeString]]];
	[item setAction:@selector(rotateLayer180)];
	[item setTarget:self];
	[subMenu addItem:item];
    
	return menu;
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	if ([self.tableView clickedRow] == -1)
		return NO;
	
	if ([anItem action] == @selector(cutSelectedLayer) || [anItem action] == @selector(removeLayer:)) {
		return [[self.canvas layers] count] > 1;
	}
	else if ([anItem action] == @selector(mergeDownSelectedLayer)) {
		NSArray *layers = [self.canvas layers];
		return [layers count] > 1 && [self.tableView clickedRow] < [layers count]-1;
	}
	
	return YES;
}

- (NSUInteger)selectionIndex
{
	if ([self.tableView clickedRow] != -1) {
		return [self.tableView clickedRow];
	}
	
	NSInteger row = [self.tableView selectedRow];
	
	if (row == -1)
		return NSNotFound;
	
	return row;
}

#pragma mark -
#pragma mark Selection

- (void)selectionDidChange:(NSNotification *)notification
{
	_ignoreSelectionChange = YES;
	[self highlightLayerAtIndex:[_canvas indexOfLayer:[_canvas activeLayer]]];
	_ignoreSelectionChange = NO;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	if (_ignoreSelectionChange)
		return;
	
	NSInteger index = [self.tableView selectedRow];
	
	if (index == -1)
		return;
	
	if (index >= [[_canvas layers] count]) {
		NSLog(@"Invalid index");
		[self selectLayerAtIndex:0];
	}
	else {
		[self propagateLayerAtIndex:[self invertLayerIndex:index]];
	}
}

- (void)propagateLayerAtIndex:(NSUInteger)index
{
	if (index == NSNotFound) {
		NSLog(@"Invalid index");
		return;
	}
	
	PXLayer *layer = [[_canvas layers] objectAtIndex:index];
	[_canvas activateLayer:layer];
}

- (void)selectNextLayer
{
	NSUInteger index = [self.tableView selectedRow];
	[self selectLayerAtIndex:[self invertLayerIndex:index+1]];
}

- (void)selectPreviousLayer
{
	NSUInteger index = [self.tableView selectedRow];
	[self selectLayerAtIndex:[self invertLayerIndex:index-1]];
}

- (void)selectLayerAtIndex:(NSUInteger)index
{
	if (index == NSNotFound || index >= [[_canvas layers] count])
	{
		NSLog(@"Invalid index");
		[self selectLayerAtIndex:[[_canvas layers] indexOfObject:[_canvas activeLayer]]];
		return;
	}
	
	[self highlightLayerAtIndex:index];
	[self propagateLayerAtIndex:index];
}

- (void)highlightLayerAtIndex:(NSUInteger)index
{
	if (index == NSNotFound || index >= [[_canvas layers] count]) {
		NSLog(@"Invalid index");
		return;
	}
	
	[self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[self invertLayerIndex:index]]
				byExtendingSelection:NO];
}

#pragma mark -
#pragma mark Adding

- (void)addedLayer:(NSNotification *)notification
{
	NSUInteger index = [[[notification userInfo] objectForKey:PXLayerIndexKey] unsignedIntegerValue];
	
	[self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[self invertLayerIndex:index]]
						  withAnimation:NSTableViewAnimationSlideDown];
	
	[self updateRemoveButtonState];
}

- (IBAction)addLayer:(id)sender
{
	_layersCreated++;
	
	PXLayer *layer = [[PXLayer alloc] initWithName:[NSString stringWithFormat:NSLocalizedString(@"New Layer %d", @"New Layer %d"), _layersCreated]
											  size:[_canvas size]
									 fillWithColor:PXGetClearColor()];
	
	[_canvas addLayer:layer];
}

- (void)promoteSelection
{
	[_canvas promoteSelection];
}

#pragma mark -
#pragma mark Cut, Copy, and Paste

- (void)copySelectedLayer
{
	NSUInteger index = [self selectionIndex];
	
	if (index == NSNotFound || index >= [[_canvas layers] count]) {
		NSLog(@"Invalid index");
		return;
	}
	
	PXLayer *layer = [[_canvas layers] objectAtIndex:[self invertLayerIndex:index]];
	[_canvas copyLayer:layer toPasteboard:[NSPasteboard generalPasteboard]];
}

- (void)cutSelectedLayer
{
	if ([[_canvas layers] count] <= 1)
		return;
	
	NSUInteger index = [self selectionIndex];
	
	if (index == NSNotFound || index >= [[_canvas layers] count]) {
		NSLog(@"Invalid index");
		return;
	}
	
	PXLayer *layer = [[_canvas layers] objectAtIndex:[self invertLayerIndex:index]];
	[_canvas cutLayer:layer];
}

- (void)pasteLayer
{
	[_canvas pasteLayer];
}

#pragma mark -
#pragma mark Duplicating

- (void)duplicateSelectedLayer
{
	NSUInteger index = [self invertLayerIndex:[self selectionIndex]];
	[_canvas duplicateLayerAtIndex:index];
}

#pragma mark -
#pragma mark Visibility

- (void)toggleVisibility
{
	NSUInteger index = [self invertLayerIndex:[self selectionIndex]];
    PXLayer *layer = [[_canvas layers] objectAtIndex:index];
    NSLog(@"%n", layer.name);
	[_canvas toggleVisibility:layer];
}

#pragma mark -
#pragma mark Removing

- (void)removedLayer:(NSNotification *)notification
{
	NSUInteger index = [[[notification userInfo] objectForKey:PXLayerIndexKey] unsignedIntegerValue];
	
	[self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:[self invertLayerIndex:index]]
						  withAnimation:NSTableViewAnimationSlideUp];
	
	[self updateRemoveButtonState];
}

- (void)removeLayerAtIndex:(NSUInteger)index
{
	if ([[_canvas layers] count] <= 1)
		return;
	
	[_canvas removeLayerAtIndex:index];
}

- (IBAction)removeLayer:(id)sender
{
	NSUInteger index = [self selectionIndex];
	
	if (index == NSNotFound || index >= [[_canvas layers] count]) {
		NSLog(@"Invalid index");
		return;
	}
	
	[self removeLayerAtIndex:[self invertLayerIndex:index]];
}

#pragma mark -
#pragma mark Merging

- (void)mergeDownLayerAtIndex:(NSUInteger)index
{
	PXLayer *layer = [[_canvas layers] objectAtIndex:index];
	[_canvas mergeDownLayer:layer];
}

- (void)mergeDownSelectedLayer
{
	NSUInteger index = [self selectionIndex];
	[self mergeDownLayerAtIndex:[self invertLayerIndex:index]];
}

#pragma mark -
#pragma mark Flipping

- (void)flipLayerHorizontally
{
	NSUInteger index = [self invertLayerIndex:[self selectionIndex]];
	PXLayer *layer = [[_canvas layers] objectAtIndex:index];
	
	[_canvas flipLayerHorizontally:layer];
}

- (void)flipLayerVertically
{
	NSUInteger index = [self invertLayerIndex:[self selectionIndex]];
	PXLayer *layer = [[_canvas layers] objectAtIndex:index];
	
	[_canvas flipLayerVertically:layer];
}

#pragma mark -
#pragma mark Rotation

- (void)rotateLayerCounterclockwise
{
	NSUInteger index = [self invertLayerIndex:[self selectionIndex]];
	PXLayer *layer = [[_canvas layers] objectAtIndex:index];
	
	[_canvas rotateLayer:layer byDegrees:90];
}

- (void)rotateLayerClockwise
{
	NSUInteger index = [self invertLayerIndex:[self selectionIndex]];
	PXLayer *layer = [[_canvas layers] objectAtIndex:index];
	
	[_canvas rotateLayer:layer byDegrees:270];
}

- (void)rotateLayer180
{
	NSUInteger index = [self invertLayerIndex:[self selectionIndex]];
	PXLayer *layer = [[_canvas layers] objectAtIndex:index];
	
	[_canvas rotateLayer:layer byDegrees:180];
}

#pragma mark -
#pragma mark Reordering

- (void)movedLayer:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSUInteger sourceIndex = [self invertLayerIndex:[[userInfo objectForKey:PXSourceIndexKey] unsignedIntegerValue]];
	NSUInteger targetIndex = [self invertLayerIndex:[[userInfo objectForKey:PXTargetIndexKey] unsignedIntegerValue]];
	
	[self.tableView moveRowAtIndex:sourceIndex toIndex:targetIndex];
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rows
	 toPasteboard:(NSPasteboard *)pboard
{
	[pboard declareTypes:[NSArray arrayWithObject:PXLayerRowPboardType] owner:self];
	
	[pboard setPropertyList:[NSNumber numberWithUnsignedInteger:[self invertLayerIndex:[rows firstIndex]]]
					forType:PXLayerRowPboardType];
	
	return YES;
}

- (NSDictionary *)imageFileOptions
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:YES], NSPasteboardURLReadingFileURLsOnlyKey,
			[NSImage imageTypes], NSPasteboardURLReadingContentsConformToTypesKey, nil];
}

- (NSDragOperation)tableView:(NSTableView *)tableView
				validateDrop:(id<NSDraggingInfo>)info
				 proposedRow:(NSInteger)row
	   proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
	if (dropOperation == NSTableViewDropOn)
		return NSDragOperationNone;
	
	if ([[[info draggingPasteboard] types] containsObject:PXLayerRowPboardType])
		return NSDragOperationMove;
	
	NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
	
	if ([[info draggingPasteboard] canReadObjectForClasses:classes options:[self imageFileOptions]])
		return NSDragOperationGeneric;
	
	return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView
	   acceptDrop:(id<NSDraggingInfo>)info
			  row:(NSInteger)row
	dropOperation:(NSTableViewDropOperation)dropOperation
{
	NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
	
	if ([[info draggingPasteboard] canReadObjectForClasses:classes options:[self imageFileOptions]])
	{
		NSArray *urls = [[info draggingPasteboard] readObjectsForClasses:classes options:[self imageFileOptions]];
		
		for (NSURL *url in urls) {
			NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
			
			[_canvas pasteLayerWithImage:image atIndex:[self invertLayerIndex:row-1]];
			
			return YES;
		}
	}
	
	if ([[[info draggingPasteboard] types] containsObject:PXLayerRowPboardType])
	{
		NSUInteger sourceIndex = [[[info draggingPasteboard] propertyListForType:PXLayerRowPboardType] unsignedIntegerValue];
		NSUInteger targetIndex = [self invertLayerIndex:row];
		
		if (sourceIndex > targetIndex)
			targetIndex++;
		
		if (targetIndex == NSNotFound)
			targetIndex = 0;
		
		if (targetIndex == sourceIndex)
			return NO;
		
		[_canvas moveLayerAtIndex:sourceIndex toIndex:targetIndex];
		
		return YES;
	}
	
	return NO;
}

#pragma mark -

@end
