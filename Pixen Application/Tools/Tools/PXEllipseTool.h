//
//  PXEllipseTool.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXLinearTool.h"

@interface PXEllipseTool : PXLinearTool

- (void)plotFilledEllipseInscribedInRect:(NSRect)bound
						   withLineWidth:(CGFloat)borderWidth
						   withFillColor:(PXColor)fillColor
								inCanvas:(PXCanvas *)canvas;

- (void)plotUnfilledEllipseInscribedInRect:(NSRect)bound
							 withLineWidth:(CGFloat)borderWidth
								  inCanvas:(PXCanvas *)canvas;

@end
