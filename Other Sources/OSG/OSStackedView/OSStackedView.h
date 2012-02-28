//
//  OSStackedView.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OSStackedView : NSView
{
  @private
	id delegate;
	id views;
	NSInteger tag;
	id selectedElement;
	id target;
	SEL singleAction, doubleAction;
	
	NSPoint dragOffset;
}

- (NSView *)selectedView;
- (NSUInteger)selectedRow;
- (void)stackSubview:(NSView *)sub;
- (void)unstackSubview:(NSView *)sub;
- (void)clearStack;
- (void)restackViews;

- (void)setTarget:tar;
- (void)setAction:(SEL)act;
- (void)setDoubleAction:(SEL)act;

- (void)setTag:(NSInteger)someTag;
- (NSInteger)tag;

@end


@interface NSObject(OSStackedViewDelegate)

- (void)stackedView:(OSStackedView *)aStackedView
	dragMovedToScreenPoint:(NSPoint)point;

- (BOOL)stackedView:(OSStackedView *)aStackedView
		  writeRows:(NSArray *)rows
	   toPasteboard:(NSPasteboard *)pboard;

- (NSDragOperation)stackedView:(OSStackedView *)aStackedView 
				  validateDrop:(id <NSDraggingInfo>)info;

- (NSDragOperation)stackedView:(OSStackedView *)aStackedView
					updateDrag:(id <NSDraggingInfo>)info;

- (BOOL)stackedView:(OSStackedView *)aStackedView
	 draggingExited:(id <NSDraggingInfo>)info;

- (BOOL)stackedView:(OSStackedView *)aStackedView
		 acceptDrop:(id <NSDraggingInfo>)info;

- (void)stackedView:(OSStackedView *)aStackedView 
	   concludeDrag:(id <NSDraggingInfo>)info;

- (void)stackedView:(OSStackedView *)aStackedView
 dragOperationEnded:(NSDragOperation)drag
		 insideView:(BOOL)inside
	insideSuperview:(BOOL)inSuper;


- (void)deleteKeyPressedInStackedView:(OSStackedView *)aStackedView;

@end
