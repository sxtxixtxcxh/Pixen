//
//  PXRectangleTool.h
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXLinearTool.h"

@interface PXRectangleTool : PXLinearTool 
{
  @private
	NSRect lastRect;
}

- (void)drawRect:(NSRect)aRect inCanvas:(PXCanvas *)aCanvas;

@end
