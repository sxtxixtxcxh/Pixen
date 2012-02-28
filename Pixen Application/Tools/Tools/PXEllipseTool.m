//
//  PXEllipseTool.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXCanvasController.h"
#import "PXCanvas.h"
#import "PXEllipseTool.h"
#import "PXShapeToolPropertiesController.h"

@implementation PXEllipseTool

#define SHAPE_PC ((PXShapeToolPropertiesController *) self.propertiesController)

- (NSString *)name
{
	return NSLocalizedString(@"ELLIPSE_NAME", @"Ellipse Tool");
}

-(NSString *)actionName
{
	return NSLocalizedString(@"ELLIPSE_ACTION", @"Drawing Ellipse");
}

- (PXToolPropertiesController *)createPropertiesController
{
	return [[PXShapeToolPropertiesController new] autorelease];
}

- (NSCursor *)cursor
{
	return [NSCursor crosshairCursor];
}

- (void)drawPointsAddingToArray:(NSMutableArray *)points
					 ifTracking:(BOOL)tracking
						  withX:(int)x
							  y:(int)y
							 cx:(int)cx
							 cy:(int)cy
					  evenWidth:(BOOL)evenWidth
					 evenHeight:(BOOL)evenHeight
					borderWidth:(CGFloat)borderWidth
					   inCanvas:(PXCanvas *)canvas
			  goingHorizontally:(BOOL)horiz
{
	int cWidth;
	for (cWidth = 0; cWidth < borderWidth; cWidth++) {
		int dx = x;
		int dy = y;
		if (horiz) {
			dx -= cWidth;
		} else {
			dy -= cWidth;
		}
		int cxp;
		int cxn;
		int cyp;
		int cyn;
		cxp = cx-evenWidth;
		cxn = cx;
		cyp = cy-evenHeight;
		cyn = cy;
		NSPoint p1 = NSMakePoint(cxp+dx, cyp+dy);
		NSPoint p2 = NSMakePoint(cxp+dx, cyn-dy);
		NSPoint p3 = NSMakePoint(cxn-dx, cyp+dy);
		NSPoint p4 = NSMakePoint(cxn-dx, cyn-dy);	
		if (tracking) {
			[points addObject:NSStringFromPoint(p1)];
			[points addObject:NSStringFromPoint(p2)];
			[points addObject:NSStringFromPoint(p3)];
			[points addObject:NSStringFromPoint(p4)];
		}
		[self drawPixelAtPoint:p1 inCanvas:canvas];
		[self drawPixelAtPoint:p2 inCanvas:canvas];
		[self drawPixelAtPoint:p3 inCanvas:canvas];
		[self drawPixelAtPoint:p4 inCanvas:canvas];
	}
}

- (NSArray *)plotEllipseInscribedInRect:(NSRect)bound
						  withLineWidth:(CGFloat)borderWidth
						 trackingPoints:(BOOL)tracking
							   inCanvas:(PXCanvas *)canvas
{
	NSMutableArray *points = [NSMutableArray array];
	int xRadius = NSWidth(bound)/2, yRadius = NSHeight(bound)/2;
	if (xRadius < 1) {
		xRadius = 1;
	}
	if (yRadius < 1) {
		yRadius = 1;
	}
	int cx = NSMinX(bound) + xRadius, cy = NSMinY(bound) + yRadius;
	int twoASquared = 2 * xRadius * xRadius;
	int twoBSquared = 2 * yRadius * yRadius;
	int x = xRadius;
	int y = 0;
	int xChange = yRadius * yRadius * (1 - 2*xRadius);
	int yChange = xRadius * xRadius;
	int error = 0;
	int stoppingX = twoBSquared * xRadius;
	int stoppingY = 0;
	BOOL evenWidth = ((float)xRadius == NSWidth(bound) / 2.0f);
	BOOL evenHeight = ((float)yRadius == NSHeight(bound) / 2.0f);
	while (stoppingX >= stoppingY) {
		[self drawPointsAddingToArray:points ifTracking:tracking withX:x y:y cx:cx cy:cy evenWidth:evenWidth evenHeight:evenHeight borderWidth:borderWidth inCanvas:canvas goingHorizontally:YES];
		y++;
		stoppingY += twoASquared;
		error += yChange;
		yChange += twoASquared;
		if ((2*error + xChange) > 0) {
			x--;
			stoppingX -= twoBSquared;
			error += xChange;
			xChange += twoBSquared;
		}
	}
	
	x = 0;
	y = yRadius;
	xChange = yRadius * yRadius;
	yChange = xRadius * xRadius * (1 - 2*yRadius);
	error = 0;
	stoppingX = 0;
	stoppingY = twoASquared * yRadius;
	
	while (stoppingX <= stoppingY) {
		[self drawPointsAddingToArray:points ifTracking:tracking withX:x y:y cx:cx cy:cy evenWidth:evenWidth evenHeight:evenHeight borderWidth:borderWidth inCanvas:canvas goingHorizontally:NO];
		x++;
		stoppingX += twoBSquared;
		error += xChange;
		xChange += twoBSquared;
		if ((2*error + yChange) > 0) {
			y--;
			stoppingY -= twoASquared;
			error += yChange;
			yChange += twoASquared;
		}
	}
	return points;
}


- (void)plotFilledEllipseInscribedInRect:(NSRect)bound
						   withLineWidth:(CGFloat)borderWidth
						   withFillColor:(PXColor)fillColor
								inCanvas:(PXCanvas *)canvas
{
	NSArray *points = [self plotEllipseInscribedInRect:bound withLineWidth:borderWidth trackingPoints:YES inCanvas:canvas];
	NSEnumerator *pointEnumerator = [points objectEnumerator];
	id start, end;
	NSPoint startPoint, endPoint;
	PXColor oldColor = self.color;
	
	if (![SHAPE_PC shouldUseMainColorForFill]) 
	{ 
		self.color = fillColor;
	}
	
	while ((start = [pointEnumerator nextObject]) 
		   && (end = [pointEnumerator nextObject])) 
	{
		startPoint = NSPointFromString(start);
		endPoint = NSPointFromString(end);
		while ([points containsObject:NSStringFromPoint(startPoint)]) {
			startPoint.y--;
		}
		startPoint.y++;
		while ([points containsObject:NSStringFromPoint(endPoint)]) {
			endPoint.y++;
		}
		if (startPoint.y > endPoint.y) {
			[self drawLineFrom:startPoint to:endPoint inCanvas:canvas];
		}
	}
	
	self.color = oldColor;
}

- (void)plotUnfilledEllipseInscribedInRect:(NSRect)bound 
							 withLineWidth:(CGFloat)borderWidth
								  inCanvas:(PXCanvas *)canvas
{
	[self plotEllipseInscribedInRect:(NSRect)bound 
					   withLineWidth:borderWidth
					  trackingPoints:NO
							inCanvas:canvas];
}

- (NSRect)getEllipseBoundFromdrawFromPoint:(NSPoint)origin toPoint:(NSPoint)aPoint
{
	NSPoint start = origin;
	NSPoint end = aPoint;
	if (aPoint.x < start.x)
	{
		start.x = aPoint.x;
		end.x = origin.x + 1;
	}
	else
	{
		end.x++;
	}
	
	if (aPoint.y < start.y)
	{
		start.y = aPoint.y;
		end.y = origin.y + 1;
	}
	else
	{
		end.y++;
	}
	return NSMakeRect(start.x, start.y, end.x - start.x, end.y - start.y);
}

- (void)finalDrawFromPoint:(NSPoint)origin toPoint:(NSPoint)aPoint inCanvas:(PXCanvas *)canvas
{
	NSRect ellipseBound = [self getEllipseBoundFromdrawFromPoint:(NSPoint)origin
														 toPoint:aPoint];
	
	if ([SHAPE_PC shouldFill]) {
		[self plotFilledEllipseInscribedInRect:ellipseBound
								 withLineWidth:[SHAPE_PC borderWidth]
								 withFillColor:[SHAPE_PC shouldUseMainColorForFill] ? [self colorForCanvas:canvas] : PXColorFromNSColor([SHAPE_PC fillColor])
									  inCanvas:canvas];
		
	} else {
		
		[self plotUnfilledEllipseInscribedInRect:ellipseBound
								   withLineWidth:[SHAPE_PC borderWidth]
										inCanvas:canvas];
	}
}

- (void)drawFromPoint:(NSPoint)origin toPoint:(NSPoint)finalPoint inCanvas:(PXCanvas *)canvas
{
	[super drawFromPoint:origin toPoint:finalPoint inCanvas:canvas];
	NSRect ellipseBound = [self getEllipseBoundFromdrawFromPoint:(NSPoint)origin
														 toPoint:finalPoint];
	[self plotUnfilledEllipseInscribedInRect:ellipseBound
							   withLineWidth:[SHAPE_PC borderWidth]
									inCanvas:canvas];
}

- (BOOL)supportsPatterns
{
	return NO;
}

@end
