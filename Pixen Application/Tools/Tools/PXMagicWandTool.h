//
//  PXMagicWandTool.h
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXFillTool.h"
#import "PXCanvas.h"

@interface PXMagicWandTool : PXFillTool
{
  @private
	BOOL isMoving, isAdding, isSubtracting;
	NSPoint origin;
	NSRect selectedRect, lastSelectedRect;
	int oldLayerIndex, oldLastLayerIndex;
	
	PXSelectionMask oldMask;
}

@end
