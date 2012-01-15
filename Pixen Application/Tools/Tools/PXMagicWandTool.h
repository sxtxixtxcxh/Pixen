//
//  PXMagicWandTool.h
//  Pixen-XCode
//
//  Created by Andy Matuschak on Sat Jun 12 2004.
//  Copyright (c) 2004 Pixen. All rights reserved.
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

