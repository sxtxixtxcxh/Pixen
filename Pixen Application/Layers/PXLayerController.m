//
//  PXLayerController.m
//  Pixen
//

#import "PXLayerController.h"

#import "PXCanvas_CopyPaste.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Selection.h"
#import "PXCanvasDocument.h"
#import "PXLayer.h"
#import "PXLayerCollectionView.h"
#import "PXLayerCollectionViewItem.h"
#import "PXLayerDetailsView.h"
#import "PXNotifications.h"

@interface PXLayerController ()

- (void)updateRemoveButtonState;

- (void)reloadData;

- (void)propagateLayerAtIndex:(NSUInteger)index;

- (NSUInteger)invertLayerIndex:(NSUInteger)index;

- (void)highlightLayerAtIndex:(NSUInteger)index;

@end


@implementation PXLayerController

@synthesize layersView = _layersView, removeButton = _removeButton, layersArray = _layersArray;
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
	
	[_layersView removeObserver:self forKeyPath:@"selectionIndexes"];
	[_layersArray release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	[_layersView setLayerController:self];
	[_layersView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
	[_layersView setDraggingSourceOperationMask:NSDragOperationNone forLocal:NO];
	[_layersView setMinItemSize:NSMakeSize(200.0f, 49.0f)];
	[_layersView setMaxItemSize:NSMakeSize(0.0f, 49.0f)];
	[_layersView registerForDraggedTypes:[NSArray arrayWithObject:PXLayerRowPboardType]];
	
	[_layersView addObserver:self
				  forKeyPath:@"selectionIndexes"
					 options:NSKeyValueObservingOptionNew
					 context:NULL];
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
		}
	}
}

#pragma mark -
#pragma mark Data

- (void)setLayers:(NSNotification *)notification
{
	[self reloadData];
}

- (void)reloadData
{
	for (NSUInteger n = 0; n < [[_layersArray arrangedObjects] count]; n++) {
		PXLayerCollectionViewItem *item = (PXLayerCollectionViewItem *) [_layersView itemAtIndex:n];
		[item unload];
	}
	
	[_layersArray removeObjects:[_layersArray arrangedObjects]];
	
	for (PXLayer *layer in [_canvas layers]) {
		[_layersArray insertObject:layer atArrangedObjectIndex:0];
	}
	
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0f);
	dispatch_after(popTime, dispatch_get_main_queue(), ^{
		
		[self selectLayerAtIndex:0];
		[self updateRemoveButtonState];
		
	});
}

- (NSUInteger)invertLayerIndex:(NSUInteger)index
{
	NSInteger newIndex = [[_canvas layers] count] - index - 1;
	
	if (newIndex < 0)
		return NSNotFound;
	
	return newIndex;
}

#pragma mark -
#pragma mark Selection

- (void)selectionDidChange:(NSNotification *)notification
{
	_ignoreSelectionChange = YES;
	[self highlightLayerAtIndex:[_canvas indexOfLayer:[_canvas activeLayer]]];
	_ignoreSelectionChange = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if (_ignoreSelectionChange)
		return;
	
	NSUInteger index = [[change objectForKey:NSKeyValueChangeNewKey] firstIndex];
	
	if (index == NSNotFound || index >= [[_canvas layers] count]) {
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
	NSUInteger index = [[_layersView selectionIndexes] firstIndex];
	[self selectLayerAtIndex:[self invertLayerIndex:index+1]];
}

- (void)selectPreviousLayer
{
	NSUInteger index = [[_layersView selectionIndexes] firstIndex];
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
	
	[_layersView setSelectionIndexes:[NSIndexSet indexSetWithIndex:[self invertLayerIndex:index]]];
}

#pragma mark -
#pragma mark Adding

- (void)addedLayer:(NSNotification *)notification
{
	PXLayer *layer = [[notification userInfo] objectForKey:PXLayerKey];
	NSUInteger index = [[[notification userInfo] objectForKey:PXLayerIndexKey] unsignedIntegerValue];
	
	[_layersArray insertObject:layer atArrangedObjectIndex:[self invertLayerIndex:index]];
	
	[self updateRemoveButtonState];
}

- (IBAction)addLayer:(id)sender
{
	_layersCreated++;
	
	PXLayer *layer = [[PXLayer alloc] initWithName:[NSString stringWithFormat:NSLocalizedString(@"New Layer %d", @"New Layer %d"), _layersCreated]
											  size:[_canvas size]
									 fillWithColor:PXGetClearColor()];
	
	[_canvas addLayer:layer];
	[layer release];
}

- (void)promoteSelection
{
	[_canvas promoteSelection];
}

#pragma mark -
#pragma mark Cut, Copy, and Paste

- (void)copySelectedLayer
{
	NSUInteger index = [[_layersView selectionIndexes] firstIndex];
	
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
	NSUInteger index = [[_layersView selectionIndexes] firstIndex];
	
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

- (void)duplicateSelectedLayer
{
	NSUInteger index = [self invertLayerIndex:[[_layersView selectionIndexes] firstIndex]];
	[_canvas duplicateLayerAtIndex:index];
}

- (void)duplicateLayerObject:(PXLayer *)layer
{
	NSUInteger index = [[_canvas layers] indexOfObject:layer];
	[_canvas duplicateLayerAtIndex:index];
}

#pragma mark -
#pragma mark Removing

- (void)removedLayer:(NSNotification *)notification
{
	NSUInteger index = [[[notification userInfo] objectForKey:PXLayerIndexKey] unsignedIntegerValue];
	
	PXLayerCollectionViewItem *item = (PXLayerCollectionViewItem *) [_layersView itemAtIndex:[self invertLayerIndex:index]];
	[item unload];
	
	[_layersArray removeObjectAtArrangedObjectIndex:[self invertLayerIndex:index]];
	
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
	NSUInteger index = [[_layersView selectionIndexes] firstIndex];
	
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
	NSUInteger index = [[_layersView selectionIndexes] firstIndex];
	[self mergeDownLayerAtIndex:[self invertLayerIndex:index]];
}

#pragma mark -
#pragma mark Reordering

- (void)movedLayer:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	NSUInteger sourceIndex = [self invertLayerIndex:[[userInfo objectForKey:PXSourceIndexKey] unsignedIntegerValue]];
	NSUInteger targetIndex = [self invertLayerIndex:[[userInfo objectForKey:PXTargetIndexKey] unsignedIntegerValue]];
	
	id obj = [[[_layersArray arrangedObjects] objectAtIndex:sourceIndex] retain];
	[_layersArray removeObjectAtArrangedObjectIndex:sourceIndex];
	[_layersArray insertObject:obj atArrangedObjectIndex:targetIndex];
	
	[obj release];
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

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView
					 validateDrop:(id < NSDraggingInfo >)info
					proposedIndex:(NSInteger *)indexP
					dropOperation:(NSCollectionViewDropOperation *)operationP {
	
	if (![[[info draggingPasteboard] types] containsObject:PXLayerRowPboardType])
		return NSDragOperationNone;
	
	if ((*operationP) == NSCollectionViewDropOn)
		*operationP = NSCollectionViewDropBefore;
	
	return NSDragOperationMove;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView
			acceptDrop:(id < NSDraggingInfo >)info
				 index:(NSInteger)index
		 dropOperation:(NSCollectionViewDropOperation)dropOperation {
	
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

#pragma mark -

@end
