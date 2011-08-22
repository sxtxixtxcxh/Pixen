//
//  PXGrid.m
//  Pixen
//

#import "PXGrid.h"

@implementation PXGrid

@synthesize color;

- (id)init
{
	self = [super init];
	[self setDefaultParameters];
	return self;
}

- (id)initWithUnitSize:(NSSize)newUnitSize
				 color:(NSColor *)newColor
			shouldDraw:(BOOL)newShouldDraw
{
	self = [self init];
	if (newColor)
	{
		[self setUnitSize:newUnitSize];
		[self setColor:newColor];
		[self setShouldDraw:newShouldDraw];
	}
	return self;
}

- initWithCoder:(NSCoder *)coder
{
	return [self initWithUnitSize:[coder decodeSizeForKey:@"gridUnitSize"] color:[coder decodeObjectForKey:@"gridColor"] shouldDraw:[coder decodeBoolForKey:@"gridShouldDraw"]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeBool:[self shouldDraw] forKey:@"gridShouldDraw"];
	[coder encodeSize:[self unitSize] forKey:@"gridUnitSize"];
	[coder encodeObject:[self color] forKey:@"gridColor"];	
}

- (void)drawRect:(NSRect)drawingRect
{
	if (!shouldDraw) 
		return; 
	
	NSSize dimensions = drawingRect.size;
	int i;
	float lineWidth = [NSBezierPath defaultLineWidth];;
	BOOL oldShouldAntialias = [[NSGraphicsContext currentContext] shouldAntialias];
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	[NSBezierPath setDefaultLineWidth:0];
	[color set];
	
	for (i = 0; i < dimensions.width + unitSize.width; i+=unitSize.width)
    {
		[NSBezierPath strokeLineFromPoint:NSMakePoint(i, 0) 
								  toPoint:NSMakePoint(i, dimensions.height)];
    }
	
	for (i = 0; i < dimensions.height + unitSize.height; i+=unitSize.height)
    {
		[NSBezierPath strokeLineFromPoint:NSMakePoint(0, i) 
								  toPoint:NSMakePoint(dimensions.width, i)];
    }
	
	[NSBezierPath setDefaultLineWidth:lineWidth];
	[[NSGraphicsContext currentContext] setShouldAntialias:oldShouldAntialias];	
}

- (NSSize)unitSize
{
	return unitSize;
}

- (BOOL)shouldDraw
{
	return shouldDraw;
}

- (void)setShouldDraw:(BOOL)newShouldDraw
{
	shouldDraw = newShouldDraw;
}

- (void)setUnitSize:(NSSize)newUnitSize
{
	unitSize = newUnitSize;
}

- (void)setDefaultParameters
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if(! [defaults objectForKey:PXGridColorDataKey] )
	{
		[self setShouldDraw:NO];
		[self setUnitSize:NSMakeSize(1,1)];
		[self setColor:[NSColor blackColor]];
	}
	else
	{
		NSSize uS;
		uS.width = [defaults floatForKey:PXGridUnitWidthKey];
		uS.height = [defaults floatForKey:PXGridUnitHeightKey];
		
		[self setShouldDraw:[defaults boolForKey:PXGridShouldDrawKey]];
		[self setUnitSize:uS];
		
		[self setColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:PXGridColorDataKey]]];	
	}
}

- copyWithZone:(NSZone *)zn
{
	id copy = [[PXGrid allocWithZone:zn] initWithUnitSize:unitSize color:color shouldDraw:shouldDraw];
	return copy;
}

@end
