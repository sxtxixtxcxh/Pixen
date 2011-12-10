//
//  PXGrid.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXGrid.h"

@implementation PXGrid

@synthesize unitSize = _unitSize, color = _color, shouldDraw = _shouldDraw;

- (id)init
{
	self = [super init];
	if (self) {
		[self setDefaultParameters];
	}
	return self;
}

- (id)initWithUnitSize:(NSSize)newUnitSize
				 color:(NSColor *)newColor
			shouldDraw:(BOOL)newShouldDraw
{
	self = [self init];
	if (newColor)
	{
		self.unitSize = newUnitSize;
		self.color = newColor;
		self.shouldDraw = newShouldDraw;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	return [self initWithUnitSize:[coder decodeSizeForKey:@"gridUnitSize"]
							color:[coder decodeObjectForKey:@"gridColor"]
					   shouldDraw:[coder decodeBoolForKey:@"gridShouldDraw"]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeBool:[self shouldDraw] forKey:@"gridShouldDraw"];
	[coder encodeObject:[self color] forKey:@"gridColor"];
	[coder encodeSize:[self unitSize] forKey:@"gridUnitSize"];
}

- (void)drawRect:(NSRect)drawingRect
{
	if (!self.shouldDraw)
		return;
	
	NSSize dimensions = drawingRect.size;
	
	CGFloat lineWidth = [NSBezierPath defaultLineWidth];;
	BOOL oldShouldAntialias = [[NSGraphicsContext currentContext] shouldAntialias];
	
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	[NSBezierPath setDefaultLineWidth:0.0f];
	
	[self.color set];
	
	for (CGFloat i = 0.0f; i < dimensions.width + self.unitSize.width; i += self.unitSize.width)
	{
		[NSBezierPath strokeLineFromPoint:NSMakePoint(i, 0.0f)
								  toPoint:NSMakePoint(i, dimensions.height)];
	}
	
	for (CGFloat i = 0.0f; i < dimensions.height + self.unitSize.height; i += self.unitSize.height)
	{
		[NSBezierPath strokeLineFromPoint:NSMakePoint(0.0f, i)
								  toPoint:NSMakePoint(dimensions.width, i)];
	}
	
	[NSBezierPath setDefaultLineWidth:lineWidth];
	
	[[NSGraphicsContext currentContext] setShouldAntialias:oldShouldAntialias];
}

- (void)setDefaultParameters
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (![defaults objectForKey:PXGridColorDataKey])
	{
		self.shouldDraw = NO;
		self.unitSize = NSMakeSize(1.0f, 1.0f);
		self.color = [NSColor blackColor];
	}
	else
	{
		self.shouldDraw = [defaults boolForKey:PXGridShouldDrawKey];
		self.unitSize = NSMakeSize([defaults floatForKey:PXGridUnitWidthKey], [defaults floatForKey:PXGridUnitHeightKey]);
		self.color = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:PXGridColorDataKey]];
	}
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[PXGrid allocWithZone:zone] initWithUnitSize:self.unitSize
												   color:self.color
											  shouldDraw:self.shouldDraw];
}

@end
