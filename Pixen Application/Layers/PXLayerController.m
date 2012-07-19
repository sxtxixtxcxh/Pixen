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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
	NSArray *types = [NSArray arrayWithObjects:PXLayerRowPboardType, NSFilenamesPboardType, nil];
	
	[self.tableView registerForDraggedTypes:types];
	[self.tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
	[self.tableView setDraggingSourceOperationMask:NSDragOperationGeneric forLocal:NO];
	[self.tableView setMenu:[self setupMenu]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tableViewSelectionDidChange:)
												 name:NSTableViewSelectionDidChangeNotification
											   object:self.tableView];
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
			[self.tableView reloadData];
			
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
		
		cellView.imageView.image = [NSImage imageWithBitmapImageRep:layer.imageRep];
		
	}];
}

- (void)updatePreview:(NSNotification *)notification
{
	[[NSRunLoop mainRunLoop] cancelPerformSelectorsWithTarget:self];
	[self performSelector:@selector(updatePreviewReal) withObject:nil afterDelay:0.05];
}

#pragma mark -
#pragma mark Data

- (void)setLayers:(NSNotification *)notification
{
	[self.tableView reloadData];
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
	NSMenu *menu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Layer", @"Layer")];
	
	NSMenuItem *item;
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Delete", @"Delete")];
	[item setAction:@selector(deleteMenu:)];
	[item setTarget:self];
	[menu addItem:item];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Duplicate", @"Duplicate")];
	[item setAction:@selector(duplicateMenu:)];
	[item setTarget:self];
	[menu addItem:item];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Merge Down", @"Merge Down")];
	[item setAction:@selector(mergeDown:)];
	[item setTarget:self];
	[menu addItem:item];
	
	[menu addItem:[NSMenuItem separatorItem]];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Cut", @"Cut")];
	[item setAction:@selector(cutLayer:)];
	[item setTarget:self];
	[menu addItem:item];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Copy", @"Copy")];
	[item setAction:@selector(copyLayer:)];
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
	[item setAction:@selector(flipLayerHorizontally:)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:NSLocalizedString(@"Flip Vertically", @"Flip Vertically")];
	[item setAction:@selector(flipLayerVertically:)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	[subMenu addItem:[NSMenuItem separatorItem]];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rotate 90%@ Left", @"Rotate 90%@ Left"), [self degreeString]]];
	[item setAction:@selector(rotateLayerCounterclockwise:)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rotate 90%@ Right", @"Rotate 90%@ Right"), [self degreeString]]];
	[item setAction:@selector(rotateLayerClockwise:)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	item = [[NSMenuItem alloc] init];
	[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rotate 180%@", @"Rotate 180%@"), [self degreeString]]];
	[item setAction:@selector(rotateLayer180:)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	return menu;
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	/*
	if ([anItem action] == @selector(mergeDown:)) {
		NSArray *layers = [[self canvas] layers];
		return [layers count] > 1 && [layers objectAtIndex:0] != [self layer];
	}
	 */
	if ([anItem action] == @selector(cutLayer:) || [anItem action] == @selector(deleteMenu:)) {
		return [[self.canvas layers] count] > 1;
	}
	
	return YES;
}

- (NSInteger)selectionIndexForContextMenu
{
	if ([self.tableView clickedRow] != -1) {
		return [self.tableView clickedRow];
	}
	
	return [self.tableView selectedRow];
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
	
	if (index == -1 || index >= [[_canvas layers] count]) {
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
	NSUInteger index = [self.tableView selectedRow];
	
	if (index == NSNotFound || index >= [[_canvas layers] count]) {
		NSLog(@"Invalid index");
		return;
	}
	
	PXLayer *layer = [[_canvas layers] objectAtIndex:[self invertLayerIndex:index]];
	[self copyLayerObject:layer];
}

- (void)copyLayerObject:(PXLayer *)layer
{
	[_canvas copyLayer:layer toPasteboard:[NSPasteboard generalPasteboard]];
}

- (void)cutSelectedLayer
{
	NSUInteger index = [self.tableView selectedRow];
	
	if (index == NSNotFound || index >= [[_canvas layers] count]) {
		NSLog(@"Invalid index");
		return;
	}
	
	PXLayer *layer = [[_canvas layers] objectAtIndex:[self invertLayerIndex:index]];
	[self cutLayerObject:layer];
}

- (void)cutLayerObject:(PXLayer *)layer
{
	if ([[_canvas layers] count] <= 1)
		return;
	
	[_canvas cutLayer:layer];
}

- (void)pasteLayer
{
	[_canvas pasteLayer];
}

#pragma mark -
#pragma mark Duplicating

- (void)duplicateMenu:(id)sender
{
	NSUInteger index = [self invertLayerIndex:[self selectionIndexForContextMenu]];
	PXLayer *layer = [[self.canvas layers] objectAtIndex:index];
	
	[self duplicateLayerObject:layer];
}

- (void)duplicateSelectedLayer
{
	NSUInteger index = [self invertLayerIndex:[self.tableView selectedRow]];
	[_canvas duplicateLayerAtIndex:index];
}

- (void)duplicateLayerObject:(PXLayer *)layer
{
	NSUInteger index = [[_canvas layers] indexOfObject:layer];
	[_canvas duplicateLayerAtIndex:index];
}

#pragma mark -
#pragma mark Removing

- (void)deleteMenu:(id)sender
{
	[self removeLayerAtIndex:[self invertLayerIndex:[self selectionIndexForContextMenu]]];
}

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

- (void)removeLayerObject:(PXLayer *)layer
{
	[self removeLayerAtIndex:[[_canvas layers] indexOfObject:layer]];
}

- (IBAction)removeLayer:(id)sender
{
	NSUInteger index = [self.tableView selectedRow];
	
	if (index == NSNotFound || index >= [[_canvas layers] count]) {
		NSLog(@"Invalid index");
		return;
	}
	
	[self removeLayerAtIndex:[self invertLayerIndex:index]];
}

- (void)deleteKeyPressedInCollectionView:(NSCollectionView *)view
{
	[self removeLayer:self];
}

#pragma mark -
#pragma mark Merging

- (void)mergeDownLayerAtIndex:(NSUInteger)index
{
	PXLayer *layer = [[_canvas layers] objectAtIndex:index];
	[_canvas mergeDownLayer:layer];
}

- (void)mergeDownLayerObject:(PXLayer *)layer
{
	[self mergeDownLayerAtIndex:[[_canvas layers] indexOfObject:layer]];
}

- (void)mergeDownSelectedLayer
{
	NSUInteger index = [self.tableView selectedRow];
	[self mergeDownLayerAtIndex:[self invertLayerIndex:index]];
}

#pragma mark -
#pragma mark Reordering

- (void)movedLayer:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSUInteger sourceIndex = [self invertLayerIndex:[[userInfo objectForKey:PXSourceIndexKey] unsignedIntegerValue]];
	NSUInteger targetIndex = [self invertLayerIndex:[[userInfo objectForKey:PXTargetIndexKey] unsignedIntegerValue]];
	
#warning TODO: rewrite
	/*
	id obj = [[_layersArray arrangedObjects] objectAtIndex:sourceIndex];
	[_layersArray removeObjectAtArrangedObjectIndex:sourceIndex];
	[_layersArray insertObject:obj atArrangedObjectIndex:targetIndex];
	 */
}

- (BOOL)collectionView:(NSCollectionView *)collectionView
   writeItemsAtIndexes:(NSIndexSet *)rows
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

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView
					 validateDrop:(id < NSDraggingInfo >)info
					proposedIndex:(NSInteger *)indexP
					dropOperation:(NSCollectionViewDropOperation *)operationP {
	
	if ([[[info draggingPasteboard] types] containsObject:PXLayerRowPboardType]) {
		if ((*operationP) == NSCollectionViewDropOn)
			*operationP = NSCollectionViewDropBefore;
		
		return NSDragOperationMove;
	}
	
	NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
	
	if ([[info draggingPasteboard] canReadObjectForClasses:classes options:[self imageFileOptions]]) {
		if ((*operationP) == NSCollectionViewDropOn)
			*operationP = NSCollectionViewDropBefore;
		
		return NSDragOperationGeneric;
	}
	
	return NSDragOperationNone;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView
			acceptDrop:(id < NSDraggingInfo >)info
				 index:(NSInteger)index
		 dropOperation:(NSCollectionViewDropOperation)dropOperation {
	
	NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
	
	if ([[info draggingPasteboard] canReadObjectForClasses:classes options:[self imageFileOptions]])
	{
		NSArray *urls = [[info draggingPasteboard] readObjectsForClasses:classes options:[self imageFileOptions]];
		
		for (NSURL *url in urls) {
			NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
			
			[_canvas pasteLayerWithImage:image atIndex:[self invertLayerIndex:index-1]];
			
			return YES;
		}
	}
	
	if ([[[info draggingPasteboard] types] containsObject:PXLayerRowPboardType])
	{
		NSUInteger sourceIndex = [[[info draggingPasteboard] propertyListForType:PXLayerRowPboardType] unsignedIntegerValue];
		NSUInteger targetIndex = [self invertLayerIndex:index];
		
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
