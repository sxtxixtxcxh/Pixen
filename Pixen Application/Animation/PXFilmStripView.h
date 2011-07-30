//
//  PXFilmStripView.h
//  PXFilmstrip
//
//  Created by Andy Matuschak on 8/9/05.
//  Copyright 2005 Pixen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PXFilmStripView : NSView
{
  @private
	IBOutlet id dataSource;
	IBOutlet id delegate;
	
	NSImage *spokeHoleCache;
	
	NSRect *celRects;
	NSInteger celRectsCount;
	NSBezierPath *spokeHolePath;
	
	NSRect updateRect;
	NSTimer *updateTimer;
	
	NSPoint dragOrigin;
	NSInteger targetDraggingIndex;
	
	NSPoint mouseLocation;
	
	NSTrackingRectTag *celTrackingTags;
	NSTrackingRectTag *closeButtonTrackingTags;
	
	NSInteger gonnaBeDeleted;
	
	NSMutableIndexSet *selectedIndices;
	BOOL allowsMultipleSelection;
	NSTextFieldCell *fieldCell;
	NSInteger activeCelForField;
}

@property (nonatomic, assign) id delegate;

- (void)setDataSource:dataSource;
- (void)reloadData;
- (float)minimumHeight;

- (void)setNeedsDelayedDisplayInRect:(NSRect)rect;

- (NSInteger)selectedIndex;
- selectedCel;
- (NSIndexSet *)selectedIndices;
- (NSArray *)selectedCels;
- (void)selectCelAtIndex:(NSInteger)index byExtendingSelection:(BOOL)extend;
- (NSRect)rectOfCelIndex:(NSInteger)index;

@end

@interface NSObject (PXFilmStripDataSource)
- (NSInteger)numberOfCels;
- celAtIndex:(NSInteger)index;
- (NSArray *)draggedTypesForFilmStripView:view;
- (void)deleteCelsAtIndices:(NSIndexSet *)indices;
- (void)writeCelsAtIndices:(NSIndexSet *)indices toPasteboard:(NSPasteboard *)pboard;
- (BOOL)insertCelIntoFilmStripView:view fromPasteboard:(NSPasteboard *)pboard atIndex:(NSInteger)targetDraggingIndex;
- (BOOL)moveCelInFilmStripView:view fromIndex:(NSInteger)index1 toIndex:(NSInteger)index2;
- (BOOL)copyCelInFilmStripView:view atIndex:(NSInteger)currentIndex toIndex:(NSInteger)anotherIndex;
@end

@interface NSObject (PXFilmStripDelegate)
- (void)filmStripSelectionDidChange:(NSNotification *)note;
@end

