//
//  PXLassoTool.h
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXTool.h"

@interface PXLassoTool : PXTool 
{
  @private
	BOOL isMoving, isAdding, isSubtracting;
	NSPoint origin;
	int leftMost, rightMost, topMost, bottomMost;
	
	NSBezierPath *linePath;
	NSRect selectedRect, lastSelectedRect;
}

- (void)startMovingCanvas:(PXCanvas *)canvas;

@end
