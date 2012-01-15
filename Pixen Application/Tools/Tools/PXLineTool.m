//
//  PXLineTool.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXLineTool.h"

#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"

@implementation PXLineTool

- (NSString *)name
{
	return NSLocalizedString(@"LINE_NAME", @"Line Tool");
}

- (NSString *)actionName
{
	return NSLocalizedString(@"LINE_ACTION", @"Drawing Line");
}

- (NSCursor *)cursor
{
	return [NSCursor crosshairCursor];
}

// Line tool doesn't need center locking, just gets in the way...

- (BOOL)optionKeyDown
{
	return NO;
}

- (BOOL)optionKeyUp
{
	return NO;
}

- (BOOL)supportsAdditionalLocking
{
	return YES;
}

- (BOOL)shouldUseBezierDrawing
{
	return shouldUseBezierDrawing || self.isClicking;
}

- (void)drawFromPoint:(NSPoint)origin
			  toPoint:(NSPoint)finalPoint
			 inCanvas:(PXCanvas *)canvas
{
	if ([canvas canDrawAtPoint:origin])
		[self drawPixelAtPoint:origin inCanvas:canvas];
	
	[self drawLineFrom:origin to:finalPoint inCanvas:canvas];
}

- (void)finalDrawFromPoint:(NSPoint)origin
				   toPoint:(NSPoint)finalPoint
				  inCanvas:(PXCanvas *)canvas
{
	shouldUseBezierDrawing = NO;
	
	[self drawPixelAtPoint:origin inCanvas:canvas];
	[self drawLineFrom:origin to:finalPoint inCanvas:canvas];
}

@end
