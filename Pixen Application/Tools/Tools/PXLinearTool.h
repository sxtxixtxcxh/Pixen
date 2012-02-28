//
//  PXLinearTool.h
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXPencilTool.h"
#import "PXCanvas.h"

// a generalized line tool
@interface PXLinearTool : PXPencilTool 
{
  @private
	NSPoint _origin;
	NSPoint _lastPoint;
	NSRect lastBounds;
	BOOL locked;
	BOOL centeredOnOrigin;
}

@property (nonatomic, assign) NSPoint origin;

- (NSPoint)transformOrigin:(NSPoint)origin withDrawingPoint:(NSPoint)aPoint;

- (void)drawFromPoint:(NSPoint)origin
			  toPoint:(NSPoint)finalPoint
			 inCanvas:(PXCanvas *) canvas;

- (void)finalDrawFromPoint:(NSPoint)origin
				   toPoint:(NSPoint)finalPoint
				  inCanvas:(PXCanvas *)canvas;

- (NSPoint)lockedPointFromUnlockedPoint:(NSPoint)unlockedPoint 
							 withOrigin:(NSPoint)origin;

- (void)fakeMouseDraggedIfNecessary;

@end
