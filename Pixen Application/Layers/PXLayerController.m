//
//  PXLayerController.m
//  Pixen
//

#import "PXLayerController.h"

#import "PXAnimationDocument.h"
#import "PXCanvas_CopyPaste.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas.h"
#import "PXCanvasDocument.h"
#import "PXLayer.h"
#import "PXLayerCollectionView.h"
#import "PXLayerCollectionViewItem.h"
#import "PXLayerDetailsView.h"
#import "PXNotifications.h"

@interface PXLayerController ()

- (void)updateRemoveButtonStatus;

- (void)reloadData;

- (void)propagateSelectedLayer:(NSUInteger)row;

- (NSUInteger)invertLayerIndex:(NSUInteger)anIndex;

@end


@implementation PXLayerController

@synthesize document, canvas;

- (id)init
{
	return [super initWithNibName:@"PXLayerController" bundle:nil];
}

- (id)initWithCanvas:(PXCanvas *)aCanvas
{
	if ( ! ( self = [self init]))
		return nil;
	
	[self setCanvas:aCanvas];
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[layersView removeObserver:self forKeyPath:@"selectionIndexes"];
	[canvas release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	[layersView setLayerController:self];
	[layersView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
	[layersView setDraggingSourceOperationMask:NSDragOperationNone forLocal:NO];
	[layersView setMinItemSize:NSMakeSize(200.0f, 49.0f)];
	[layersView setMaxItemSize:NSMakeSize(0.0f, 49.0f)];
	[layersView registerForDraggedTypes:[NSArray arrayWithObject:PXLayerRowPboardType]];
	
	[layersView addObserver:self
				 forKeyPath:@"selectionIndexes"
					options:NSKeyValueObservingOptionNew
					context:NULL];
}

- (void)canvasLayerChanged:(NSNotification *)notification
{
	[self selectRow:[canvas indexOfLayer:[canvas activeLayer]]];
}

- (void)updateRemoveButtonStatus
{
	[removeButton setEnabled:([[canvas layers] count] > 1)];
}

- (BOOL)isSubviewCollapsed
{
	return [ (NSSplitView *) [subview superview] isSubviewCollapsed:subview];
}

- (void)setCanvas:(PXCanvas *)aCanvas
{
	if (canvas != aCanvas)
	{
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc removeObserver:self];
		
		[canvas release];
		canvas = [aCanvas retain];
		
		if (canvas)
		{
			[nc addObserver:self
				   selector:@selector(canvasLayerChanged:)
					   name:PXCanvasLayerSelectionDidChangeName
					 object:canvas];
			
			[self reloadData];
		}
	}
}

- (void)reloadData
{
	for (NSUInteger n = 0; n < [[layersArray arrangedObjects] count]; n++) {
		PXLayerCollectionViewItem *item = (PXLayerCollectionViewItem *) [layersView itemAtIndex:n];
		[item unload];
	}
	
	[layersArray removeObjects:[layersArray arrangedObjects]];
	
	for (PXLayer *layer in [canvas layers]) {
		[layersArray insertObject:layer atArrangedObjectIndex:0];
	}
	
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.0f);
	dispatch_after(popTime, dispatch_get_main_queue(), ^{
		[self selectRow:0];
	});
}

- (void)selectNextLayer
{
	[self selectRow:[self invertLayerIndex:[[layersView selectionIndexes] firstIndex]+1]];
}

- (void)selectPreviousLayer
{
	[self selectRow:[self invertLayerIndex:[[layersView selectionIndexes] firstIndex]-1]];
}

- (void)selectRow:(NSUInteger)index
{
	if (index == NSNotFound || index >= [[canvas layers] count])
	{
		[self selectRow:[[canvas layers] indexOfObject:[canvas activeLayer]]];
		return;
	}
	
	[layersView setSelectionIndexes:[NSIndexSet indexSetWithIndex:[self invertLayerIndex:index]]];
	
	[self updateRemoveButtonStatus];
	[self propagateSelectedLayer:index];
}

- (void)setSubview:(NSView *)sv
{
	if (subview == sv)
		return;
	
	subview = sv;
	lastSubviewHeight = [subview frame].size.height;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(splitViewWillResizeSubviews:)
												 name:NSSplitViewWillResizeSubviewsNotification
											   object:[subview superview]];
}

// this is the handler the snippet above refers to
- (void)splitViewWillResizeSubviews:(id)object
{
	lastSubviewHeight = [subview frame].size.height;
}

// wire this to the UI control you wish to use to toggle the
// expanded / collapsed state of splitViewSubViewLeft
- (void)expandSubview
{
	NSSplitView *splitView = (NSSplitView *) [subview superview];
	[splitView adjustSubviews];
	
	if ([splitView isSubviewCollapsed:subview]) {
		[splitView setPosition:lastSubviewHeight ofDividerAtIndex:0];
	}
}

- (void)collapseSubview
{
	NSSplitView *splitView = (NSSplitView *) [subview superview];
	[splitView adjustSubviews];
	
	if ([splitView isSubviewCollapsed:subview]) {
		[splitView setPosition:[splitView minPossiblePositionOfDividerAtIndex:0]
			  ofDividerAtIndex:0];
	}
}

- (IBAction)addLayer:(id)sender
{
	layersCreated++;
	
	PXLayer *layer = [[PXLayer alloc] initWithName:[NSString stringWithFormat:NSLocalizedString(@"New Layer %d", @"New Layer %d"), layersCreated]
											  size:[canvas size]
									 fillWithColor:[[NSColor clearColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
	
	//[[[self document] undoManager] beginUndoGrouping];
	
	[canvas addLayer:layer];
	[layer release];
	
	//[[[self document] undoManager] endUndoGrouping];
	
	[layersArray insertObject:layer atArrangedObjectIndex:0];
	
	[self selectRow:[[canvas layers] count]];
}

- (void)promoteSelection
{
	PXLayer *layer = [canvas promoteSelection];
	[layersArray insertObject:layer atArrangedObjectIndex:0];
	
	[self selectRow:[[canvas layers] count]];
}

- (void)copySelectedLayer
{
	NSUInteger idx = [[layersView selectionIndexes] indexGreaterThanOrEqualToIndex:0];
	
	if (idx == NSNotFound || idx >= [[canvas layers] count])
		return;
	
	PXLayer *layer = [[canvas layers] objectAtIndex:[self invertLayerIndex:idx]];
	[self copyLayerObject:layer];
}

- (void)copyLayerObject:(PXLayer *)layer
{
	[canvas copyLayer:layer toPasteboard:[NSPasteboard generalPasteboard]];
}

- (void)cutSelectedLayer
{
	NSUInteger idx = [[layersView selectionIndexes] indexGreaterThanOrEqualToIndex:0];
	
	if (idx == NSNotFound || idx >= [[canvas layers] count])
		return;
	
	PXLayer *layer = [[canvas layers] objectAtIndex:[self invertLayerIndex:idx]];
	[self cutLayerObject:layer];
}

- (void)cutLayerObject:(PXLayer *)layer
{
	if ([[canvas layers] count] <= 1)
		return;
	
	NSUInteger index = [[canvas layers] indexOfObject:layer];
	
	PXLayerCollectionViewItem *item = (PXLayerCollectionViewItem *) [layersView itemAtIndex:[self invertLayerIndex:index]];
	[item unload];
	
	[layersArray removeObjectAtArrangedObjectIndex:[self invertLayerIndex:index]];
	[canvas cutLayer:layer];
	
	[self selectRow:MAX(index - 1, 0)];
}

- (void)duplicateSelectedLayer
{
	NSInteger index = [self invertLayerIndex:[[layersView selectionIndexes] firstIndex]];
	
	PXLayer *dupLayer = [canvas duplicateLayerAtIndex:index++];
	[layersArray insertObject:dupLayer atArrangedObjectIndex:[self invertLayerIndex:index]];
	
	[self selectRow:index];
}

- (void)duplicateLayerObject:(PXLayer *)layer
{
	NSInteger index = [[canvas layers] indexOfObject:layer];
	
	PXLayer *dupLayer = [canvas duplicateLayerAtIndex:index++];
	[layersArray insertObject:dupLayer atArrangedObjectIndex:[self invertLayerIndex:index]];
	
	[self selectRow:index];
}

- (void)removeLayerAtCanvasLayersIndex:(NSUInteger)index
{
	if ([[canvas layers] count] <= 1)
		return;
	
	PXLayerCollectionViewItem *item = (PXLayerCollectionViewItem *) [layersView itemAtIndex:[self invertLayerIndex:index]];
	[item unload];
	
	[layersArray removeObjectAtArrangedObjectIndex:[self invertLayerIndex:index]];
	[canvas removeLayerAtIndex:index];
	
	NSUInteger newIndex = MAX(index - 1, 0);
	[self selectRow:newIndex];
}

- (void)removeLayerObject:(PXLayer *)layer
{
	[self removeLayerAtCanvasLayersIndex:[[canvas layers] indexOfObject:layer]];
}

- (IBAction)removeLayer:(id)sender
{
	NSUInteger idx = [[layersView selectionIndexes] indexGreaterThanOrEqualToIndex:0];
	
	if (idx == NSNotFound || idx >= [[canvas layers] count])
		return;
	
	[self removeLayerAtCanvasLayersIndex:[self invertLayerIndex:idx]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if (!canvas)
		return;
	
	NSIndexSet *newSel = [change objectForKey:NSKeyValueChangeNewKey];
	NSUInteger idx = [newSel indexGreaterThanOrEqualToIndex:0];
	
	if (idx == NSNotFound || idx >= [[canvas layers] count]) {
		[self selectRow:0];
	}
	else {
		[self propagateSelectedLayer:[self invertLayerIndex:idx]];
	}
}

- (void)propagateSelectedLayer:(NSUInteger)row
{
	if (!canvas || row == NSNotFound)
		return;
	
	PXLayer *layer = [[canvas layers] objectAtIndex:row];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc postNotificationName:PXLayerSelectionDidChangeName
					  object:self
					userInfo:[NSDictionary dictionaryWithObject:layer forKey:PXLayerKey]];
}

- (NSUInteger)invertLayerIndex:(NSUInteger)anIndex
{
	NSInteger idx = [[canvas layers] count] - anIndex - 1;
	
	if (idx < 0)
		return NSNotFound;
	
	return idx;
}

- (void)mergeDownLayerAtCanvasLayersIndex:(NSUInteger)index
{
	if (index >= [[canvas layers] count])
		return;
	
	PXLayerCollectionViewItem *item = (PXLayerCollectionViewItem *) [layersView itemAtIndex:[self invertLayerIndex:index]];
	[item unload];
	
	[layersArray removeObjectAtArrangedObjectIndex:[self invertLayerIndex:index]];
	
	PXLayer *layer = [[canvas layers] objectAtIndex:index];
	BOOL wasActive = layer == [canvas activeLayer];
	[canvas mergeDownLayer:layer];
	
	if (wasActive) {
		[self selectRow:MAX(index - 1, 0)];
	}
	else {
		[self selectRow:[canvas indexOfLayer:[canvas activeLayer]]];
	}
}

- (void)mergeDownLayerObject:(PXLayer *)layer
{
	[self mergeDownLayerAtCanvasLayersIndex:[[canvas layers] indexOfObject:layer]];
}

- (void)mergeDownSelectedLayer
{
	[self mergeDownLayerAtCanvasLayersIndex:[self invertLayerIndex:[[layersView selectionIndexes] firstIndex]]];
}

- (BOOL)collectionView:(NSCollectionView *)cv
   writeItemsAtIndexes:(NSIndexSet *)rows
		  toPasteboard:(NSPasteboard *)pboard
{
	[pboard declareTypes:[NSArray arrayWithObject:PXLayerRowPboardType] owner:self];
	[pboard setString:[NSString stringWithFormat:@"%d", [self invertLayerIndex:[rows firstIndex]]] forType:PXLayerRowPboardType];
	
	return YES;
}

/*

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView
					 validateDrop:(id < NSDraggingInfo >)info
					proposedIndex:(NSInteger *)idxP
					dropOperation:(NSCollectionViewDropOperation *)operationP {
	
	if (![[[info draggingPasteboard] types] containsObject:PXLayerRowPboardType])
		return NSDragOperationNone;
	
	NSInteger idx = *idxP;
	NSCollectionViewDropOperation operation = *operationP;
	
	NSUInteger sourceIdx = [self invertLayerIndex:[[[info draggingPasteboard] stringForType:PXLayerRowPboardType] intValue]];
	if ( idx == sourceIdx + 1 || idx == sourceIdx)
	{
		return NSDragOperationNone;
	}
	
	if (operation == NSCollectionViewDropOn) 
	{ 
		if (idx == sourceIdx - 1)
			return NSDragOperationNone;
		*operationP = NSCollectionViewDropBefore;
	}
	
	return NSDragOperationMove;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView
			acceptDrop:(id < NSDraggingInfo >)info
				 index:(NSInteger)idx
		 dropOperation:(NSCollectionViewDropOperation)dropOperation {
	
	PXLayer *layer = [[canvas layers] objectAtIndex:[[[info draggingPasteboard] stringForType:PXLayerRowPboardType] intValue]];
	
	[canvas moveLayer:layer toIndex:[self invertLayerIndex:idx]];
	[self selectRow:[[canvas layers] indexOfObject:layer]];
	
	return YES;
}

- (NSImage *)collectionView:(NSCollectionView *)collectionView
draggingImageForItemsAtIndexes:(NSIndexSet *)dragIndexes
				  withEvent:(NSEvent *)dragEvent
					 offset:(NSPointPointer)dragImageOffset {
	
	PXLayerDetailsView *v = (PXLayerDetailsView *) [[collectionView itemAtIndex:[dragIndexes firstIndex]] view];
	
	NSData *viewData = [v dataWithPDFInsideRect:[v bounds]];
	NSImage *viewImage = [[[NSImage alloc] initWithData:viewData] autorelease];
	NSImage *bgImage = [[[NSImage alloc] initWithSize:[v bounds].size] autorelease];
	[bgImage lockFocus];
	[[[NSColor whiteColor] colorWithAlphaComponent:0.66] set];
	NSRectFill([v bounds]);
	[[[NSColor lightGrayColor] colorWithAlphaComponent:0.66] set];
	[[NSBezierPath bezierPathWithRect:[v bounds]] stroke];
	[viewImage compositeToPoint:NSZeroPoint fromRect:[v bounds] operation:NSCompositeSourceOver fraction:0.66];
	[bgImage unlockFocus];
	
	NSPoint locationInView = [v convertPoint:[dragEvent locationInWindow] fromView:nil];
	locationInView.x -= NSWidth([v frame]) / 2;
	locationInView.x *= -1;
	locationInView.y -= NSHeight([v frame]) / 2;
	locationInView.y *= -1;
	*dragImageOffset = locationInView;
	
	return bgImage;
}
*/

- (void)deleteKeyPressedInCollectionView:(NSCollectionView *)view
{
	[self removeLayer:self];
}

@end
