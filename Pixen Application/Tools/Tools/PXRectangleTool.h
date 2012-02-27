//
//  PXRectangleTool.h
//  Pixen-XCode
//
//  Created by Andy Matuschak on Wed Mar 10 2004.
//  Copyright (c) 2004 Pixen. All rights reserved.
//

#import "PXLinearTool.h"

@interface PXRectangleTool : PXLinearTool 
{
  @private
	NSRect lastRect;
}

- (void)drawRect:(NSRect)aRect inCanvas:(PXCanvas *)aCanvas;

@end
