//
//  PXPencilTool.m
//  Pixen
//
//  Copyright 2003-2012 Pixen Project. All rights reserved.
//

#import "PXPencilTool.h"
#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Drawing.h"
#import "PXCanvasController.h"
#import "PXCanvasView.h"
#import "PXPencilToolPropertiesController.h"
#import "InterpolatePoint.h"

@implementation PXPencilTool

#define PENCIL_PC ((PXPencilToolPropertiesController *) self.propertiesController)

- (NSString *)name
{
	return NSLocalizedString(@"PENCIL_NAME", @"Pencil Tool");
}

- (BOOL)shiftKeyDown
{
	if (isDragging) { return NO; }
	shiftDown = YES;
	return YES;
}

- (BOOL)shiftKeyUp
{
	shiftDown = NO;
	return YES;
}

-(id)  init
{
	if (! ( self = [super init] ) ) 
		return nil;
	
	shiftDown = NO;
	changedRect = NSZeroRect;
	return self;
}

- (NSCursor *)cursor
{
	static NSCursor *cursor;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(24.0f, 24.0f)];
		
		cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSZeroPoint];
		[image release];
	});
	
	return cursor;
}

- (PXToolPropertiesController *)createPropertiesController
{
	PXPencilToolPropertiesController *controller = [[PXPencilToolPropertiesController new] autorelease];
	[controller setToolName:[self name]];
	
	return controller;
}

- (NSString *)actionName
{
	return NSLocalizedString(@"PENCIL_ACTION", @"Drawing");
}

- (void)drawWithOldColor:(PXColor)oldColor
				newColor:(PXColor)newColor
				 atPoint:(NSPoint)aPoint
				 inLayer:(PXLayer *)aLayer
				ofCanvas:(PXCanvas *)aCanvas
{
	if (![aCanvas canDrawAtPoint:aPoint]) {
		return;
    }
	
	if ([self shouldUseBezierDrawing])
	{
		[self.path appendBezierPathWithRect:NSMakeRect(aPoint.x, aPoint.y, 1, 1)];
		if ([aCanvas wraps]) {
			NSSize canvasSize = [aCanvas size];
			while (aPoint.x >= canvasSize.width) {
				aPoint.x -= canvasSize.width;
			}
			while (aPoint.y >= canvasSize.height) {
				aPoint.y -= canvasSize.height;
			}
			while (aPoint.x < 0) {
				aPoint.x += canvasSize.width;
			}
			while (aPoint.y < 0) {
				aPoint.y += canvasSize.height;
			}
			[self.wrappedPath appendBezierPathWithRect:NSMakeRect(aPoint.x, aPoint.y, 1, 1)];
		}
	}
	else // if (![oldColor isEqualTo:newColor])
	{
		[aCanvas bufferUndoAtPoint:aPoint fromColor:oldColor toColor:newColor];
		[aCanvas setColor:newColor atPoint:aPoint onLayer:aLayer];
		
		if (!NSEqualRects(changedRect, NSZeroRect)) {
			changedRect = NSUnionRect(changedRect, NSMakeRect(aPoint.x, aPoint.y, 1, 1));
		}
		else {
			changedRect = NSMakeRect(aPoint.x, aPoint.y, 1, 1);
		}
	}
}

- (void)drawPixelAtPoint:(NSPoint)aPoint inCanvas:(PXCanvas *)aCanvas
{
	if (![self.propertiesController respondsToSelector:@selector(lineThickness)]) {
		if (![aCanvas containsPoint:aPoint])
			return;
		
		[self drawWithOldColor:[aCanvas colorAtPoint:aPoint]
					  newColor:[self colorForCanvas:aCanvas]
					   atPoint:aPoint
					   inLayer:[aCanvas activeLayer]
					  ofCanvas:aCanvas];
		
		return;
	}
	
	if ([PENCIL_PC drawingPoints] != nil) {
		NSArray *points = [PENCIL_PC drawingPoints];
		
		for (NSString *string in points)
		{
			NSPoint point = NSPointFromString(string);
			point.x += ceilf(aPoint.x - ([PENCIL_PC patternSize].width / 2));
			point.y += ceilf(aPoint.y - ([PENCIL_PC patternSize].height / 2));
			
			if (![aCanvas containsPoint:point]) {
				continue;
			}
			
			[self drawWithOldColor:[aCanvas colorAtPoint:point]
						  newColor:[self colorForCanvas:aCanvas]
						   atPoint:point
						   inLayer:[aCanvas activeLayer]
						  ofCanvas:aCanvas];
		}
		
		return;
	}
	
	int diameter = [PENCIL_PC lineThickness];
	int radius = diameter/2;
	NSRect rect = NSMakeRect(aPoint.x-radius, aPoint.y-radius, diameter, diameter);
	int x,y;
	
	for (x=NSMinX(rect); x<NSMaxX(rect); x++) {
		for (y=NSMinY(rect); y<NSMaxY(rect); y++) {
			NSPoint loc = NSMakePoint(x,y);
			
			if (![aCanvas containsPoint:loc]) {
				continue;
			}
			
			[self drawWithOldColor:[aCanvas colorAtPoint:loc]
						  newColor:[self colorForCanvas:aCanvas]
						   atPoint:loc
						   inLayer:[aCanvas activeLayer]
						  ofCanvas:aCanvas];
		}
	}
}

- (void)drawLineFrom:(NSPoint)initialPoint 
				  to:(NSPoint)finalPoint 
			inCanvas:(PXCanvas *) canvas
{
	NSPoint differencePoint = NSMakePoint(finalPoint.x - initialPoint.x, finalPoint.y - initialPoint.y);
    NSPoint currentPoint = initialPoint;    
    while(!NSEqualPoints(finalPoint, currentPoint))
    {
		currentPoint = InterpolatePointFromPointByPoint(currentPoint, initialPoint, differencePoint);
		if([canvas canDrawAtPoint:currentPoint])
		{
			[self drawPixelAtPoint:currentPoint inCanvas:canvas]; 
		}
    }
}

- (BOOL)shouldUseBezierDrawing
{
	return shouldUseBezierDrawing;
}

- (BOOL)drawsInitialPixel
{
	return YES;
}

- (void)mouseDownAt:(NSPoint)aPoint
fromCanvasController:(PXCanvasController*) controller
{
	[super mouseDownAt:aPoint fromCanvasController:controller];
	shouldUseBezierDrawing = NO;
	[[[controller canvas] undoManager] setActionName:[self actionName]];
	isDragging = YES;
	[[controller canvas] clearUndoBuffers];
	[[controller canvas] beginColorUpdates];
	if (![self drawsInitialPixel]) { return; }
	if (!shiftDown || [controller lastDrawnPoint].x == -1) {
		[self drawPixelAtPoint:aPoint inCanvas:[controller canvas]];
		[[controller canvas] changedInRect:NSMakeRect(aPoint.x, aPoint.y, 1, 1)];
	} else {
		[self drawLineFrom:[controller lastDrawnPoint] to:aPoint inCanvas:[controller canvas]];
	}
	[controller setLastDrawnPoint:aPoint];
}

- (void)mouseMovedTo:(NSPoint)aPoint
fromCanvasController:(PXCanvasController *)controller
{
	if([controller canvas] == nil) { return; }
	shouldUseBezierDrawing = YES;
	if ([self shouldUseBezierDrawing] && !NSEqualPoints(movingOrigin, aPoint))
	{	
		self.path = [NSBezierPath bezierPath];
		self.wrappedPath = [NSBezierPath bezierPath];
		
		movingOrigin = aPoint;
		[self drawPixelAtPoint:aPoint inCanvas:[controller canvas]];
		[[controller canvas] changedInRect:lastBezierBounds];
		if (![self.path isEmpty]) {
			int factor = [[controller view] zoomPercentage] / 100;
			
			if (factor == 0)
				factor = -12;
			
			NSRect bezierBounds = NSInsetRect([self.path bounds], MIN(-12+factor, 0), MIN(-12+factor, 0));
			[[controller canvas] changedInRect:bezierBounds];
			lastBezierBounds = bezierBounds;
		}
	}
	if (self.isClicking) {
		shouldUseBezierDrawing = NO;
	}
}

- (void)clearBezier
{
	lastBezierBounds = NSZeroRect;
	movingOrigin = NSMakePoint(-1,-1);
	[self.path removeAllPoints];
}

- (NSRect)crosshairRectCenteredAtPoint:(NSPoint)aPoint
{
	if (self.path == nil || [self.path isEmpty]) {
		return [super crosshairRectCenteredAtPoint:aPoint];
	}
	return [self.path bounds];
}

- (void)drawRectOnTop:(NSRect)rect inView:(PXCanvasView *)view withTransform:(NSAffineTransform *)transform
{
	if (![self.path elementCount])
		return;
	
	[transform invert];
	[transform concat];
	
	CGFloat x = NSMidX([self.path bounds]);
	CGFloat y = NSMidY([self.path bounds]);
	
	CGFloat factor = [view zoomPercentage] / 100;
	 
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(context);
	CGContextSetLineWidth(context, 1.0);
	
	CGMutablePathRef path1 = CGPathCreateMutable();
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor)-10,floorf(y*factor));
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor)-7,floorf(y*factor));
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor)-4,floorf(y*factor));
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor)-3,floorf(y*factor));
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor)+3,floorf(y*factor));
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor)+4,floorf(y*factor));
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor)+7,floorf(y*factor));
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor)+10,floorf(y*factor));
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)-10);
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)-7);
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)-4);
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)-3);
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)+3);
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)+4);
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)+7);
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)+10);
	
	CGContextAddPath(context, path1);
	CGPathRelease(path1);
	
	CGContextSetRGBStrokeColor(context, 0.2f, 0.2f, 0.2f, 1.0f);
	CGContextStrokePath(context);
	
	path1 = CGPathCreateMutable();
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor)-12,floorf(y*factor));
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor)-11,floorf(y*factor));
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor)-6,floorf(y*factor));
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor)-5,floorf(y*factor));
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor)+5,floorf(y*factor));
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor)+6,floorf(y*factor));
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor)+11,floorf(y*factor));
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor)+12,floorf(y*factor));
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)-12);
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)-11);
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)-6);
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)-5);
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)+5);
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)+6);
	
	CGPathMoveToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)+11);
	CGPathAddLineToPoint(path1, NULL, floorf(x*factor),floorf(y*factor)+12);
	
	CGContextAddPath(context, path1);
	CGPathRelease(path1);
	
	CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
	CGContextStrokePath(context);
	
	CGContextRestoreGState(context);
	
	[transform invert];
}

- (void)mouseDraggedFrom:(NSPoint)initialPoint 
					  to:(NSPoint)finalPoint
    fromCanvasController:(PXCanvasController *)controller
{
	if (!shiftDown) {
		[controller setLastDrawnPoint:finalPoint];
		[self drawLineFrom:initialPoint to:finalPoint inCanvas:[controller canvas]];
		[self mouseMovedTo:finalPoint fromCanvasController:controller];
	}
	if (!NSEqualRects(changedRect, NSZeroRect))
	{
		[[controller canvas] changedInRect:changedRect];
		changedRect = NSZeroRect;
	}
}

- (void)mouseUpAt:(NSPoint)aPoint 
fromCanvasController:(PXCanvasController *) controller
{
	[[controller canvas] registerForUndo];
	[[controller canvas] endColorUpdates];
	[super mouseUpAt:aPoint fromCanvasController:controller];
	isDragging = NO;
	shouldUseBezierDrawing = NO;
	if (!NSEqualRects(changedRect, NSZeroRect))
	{
		[[controller canvas] changedInRect:changedRect];
		changedRect = NSZeroRect;
	}
}

- (BOOL)supportsPatterns
{
	return YES;
}

- (void)setPattern:(PXPattern *)pattern
{
	if (![self supportsPatterns]) { return; }
	[PENCIL_PC setPattern:pattern];
}

@end
