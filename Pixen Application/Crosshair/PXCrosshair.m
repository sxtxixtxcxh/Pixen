//
//  PXCrosshair.m
//  Pixen
//

#import "PXCrosshair.h"
#import "PXToolPaletteController.h"
#import "PXTool.h"
#import "PXDefaults.h"
#import <AppKit/NSGraphicsContext.h>
#import <AppKit/NSBezierPath.h>
#import <AppKit/NSColor.h>

@implementation PXCrosshair

@synthesize cursorPosition;

- (void)drawRect:(NSRect)drawingRect withTool:tool tileOffset:(NSPoint)offset
{
	if (![self shouldDraw]) 
		return; 
	
	NSRect rect = [tool crosshairRectCenteredAtPoint:cursorPosition];
	rect.origin.x += offset.x;
	rect.origin.y += offset.y;
	
	float lineWidth;
	BOOL oldShouldAntialias = [[NSGraphicsContext currentContext] shouldAntialias];
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	lineWidth = [NSBezierPath defaultLineWidth];
	[NSBezierPath setDefaultLineWidth:0];
	[[self color] set];
	
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(rect), NSMinY(drawingRect)) 
							  toPoint:NSMakePoint(NSMinX(rect), NSMaxY(drawingRect))];
	
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(drawingRect), NSMinY(rect)) 
							  toPoint:NSMakePoint(NSMaxX(drawingRect), NSMinY(rect))];
	
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(rect), NSMinY(drawingRect))
							  toPoint:NSMakePoint(NSMaxX(rect), NSMaxY(drawingRect))];
	
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(drawingRect), NSMaxY(rect)) 
							  toPoint:NSMakePoint(NSMaxX(drawingRect), NSMaxY(rect))];
	
	[NSBezierPath setDefaultLineWidth:lineWidth];
	
	[[NSGraphicsContext currentContext] setShouldAntialias:oldShouldAntialias];     
}

-(NSColor *) color
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSData *colorData = [defaults objectForKey:PXCrosshairColorKey];
	
	if (! colorData)
    {
		colorData = [NSArchiver archivedDataWithRootObject:[NSColor redColor]];
		[defaults setObject:colorData forKey:PXCrosshairColorKey];
	}
	
	return [NSUnarchiver unarchiveObjectWithData:colorData];
}

- (BOOL)shouldDraw
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	return [defaults boolForKey:PXCrosshairEnabledKey];
}

@end
