//
//  PXPattern.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXPattern.h"

@implementation PXPattern

@synthesize size = _size;

- (id)copyWithZone:(NSZone *)zone
{
	PXPattern *newPattern = [[PXPattern alloc] init];
	[newPattern setSize:self.size];
	
	NSMutableSet *pointsCopy = [_points mutableCopy];
	[newPattern setPoints:pointsCopy];
	
	return newPattern;
}

- (id)init
{
	self = [super init];
	if (self) {
		_points = [[NSMutableSet alloc] init];
		self.size = NSMakeSize(1.0f, 1.0f);
	}
	return self;
}

- (NSString *)sizeString
{
	return [NSString stringWithFormat:@"%dx%d", (int)[self size].width, (int)[self size].height];
}

- (NSImage *)image
{
	NSSize patternSize = [self size];
	NSSize maxSize = NSMakeSize(64, 64);
	
	float scale;
	
	if (maxSize.height / patternSize.height < maxSize.width / patternSize.width) {
		scale = maxSize.height / patternSize.height;
	}
	else {
		scale = maxSize.width / patternSize.width;
	}
	
	NSRect imageRect = NSMakeRect(0.0f, 0.0f, 66.0f, 66.0f);
	
	NSImage *image = [[NSImage alloc] initWithSize:imageRect.size];
	[image lockFocus];
	
	[[NSColor grayColor] set];
	NSRectFill(imageRect);
	
	[[NSColor whiteColor] set];
	NSRectFill(NSInsetRect(imageRect, 1.0f, 1.0f));
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform translateXBy:1.0f yBy:1.0f];
	[transform scaleBy:scale];
	[transform concat];
	[self drawRect:NSMakeRect(0.0f, 0.0f, patternSize.width, patternSize.height)];
	[transform invert];
	[transform concat];
	
	[image unlockFocus];
	
	return image;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	if (self) {
		_points = [[coder decodeObjectForKey:@"points"] mutableCopy];
		self.size = [coder decodeSizeForKey:@"size"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:_points forKey:@"points"];
	[coder encodeSize:self.size forKey:@"size"];
}

- (void)setSize:(NSSize)newSize
{
	_size = newSize;
	_pointsInBounds = nil;
}

- (void)setPoints:(NSMutableSet *)newPoints
{
	_points = newPoints;
	_pointsInBounds = nil;
}

- (BOOL)hasPixelAtPoint:(NSPoint)point
{
	NSString *string = NSStringFromPoint(point);
	return [_points containsObject:string];
}

- (void)togglePoint:(NSPoint)point
{
	if ([self hasPixelAtPoint:point]) {
		[self removePoint:point];
	}
	else {
		[self addPoint:point];
	}
}

- (void)addPoint:(NSPoint)point
{
	[_points addObject:NSStringFromPoint(point)];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternChangedNotificationName
														object:self
													  userInfo:nil];
	
	_pointsInBounds = nil;
}

- (void)removePoint:(NSPoint)point
{
	[_points removeObject:NSStringFromPoint(point)];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternChangedNotificationName
														object:self
													  userInfo:nil];
	
	_pointsInBounds = nil;
}

- (NSArray *)pointsInPattern
{
	if (_pointsInBounds == nil) {
		_pointsInBounds = [[NSMutableArray alloc] init];
		
		for (NSString *string in _points)
		{
			NSPoint point = NSPointFromString(string);
			
			if (point.x >= 0 && point.y >= 0 && point.x < [self size].width && point.y < [self size].height) {
				[_pointsInBounds addObject:string];
			}
		}
	}
	
	return _pointsInBounds;
}

- (void)drawRect:(NSRect)rect
{
	[[NSColor blackColor] set];
	
	NSRect pixel;
	pixel.size = NSMakeSize(1.0f, 1.0f);
	
	for (NSString *string in _points)
	{
		pixel.origin = NSPointFromString(string);
		
		if (NSIntersectsRect(rect, pixel)) {
			NSRectFill(pixel);
		}
	}
}

@end
