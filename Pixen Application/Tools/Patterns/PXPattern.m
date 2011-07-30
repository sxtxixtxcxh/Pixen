//
//  PXPattern.m
//  Pixen
//

#import "PXPattern.h"


@implementation PXPattern

- copyWithZone:(NSZone *)zone
{
	PXPattern *newPattern = [[PXPattern alloc] init];
	[newPattern setSize:size];
	NSMutableSet *pointsCopy = [points mutableCopy];
	[newPattern setPoints:pointsCopy];
	[pointsCopy release];
	return newPattern;
}

- (id)init
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	points = [[NSMutableSet alloc] init];
	size = NSMakeSize(1, 1);
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	if (self != nil) {
		points = [[coder decodeObjectForKey:@"points"] mutableCopy];
		size = [coder decodeSizeForKey:@"size"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:points forKey:@"points"];
	[coder encodeSize:size forKey:@"size"];
}

- (void)dealloc
{
	[points release];
	[pointsInBounds release];
	[super dealloc];
}

- (void)setSize:(NSSize)newSize
{
	size = newSize;
	[pointsInBounds release];
	pointsInBounds = nil;
}

- (void)setPoints:(NSMutableSet *)newPoints
{
	[newPoints retain];
	[points release];
	points = newPoints;
	[pointsInBounds release];
	pointsInBounds = nil;
}

- (NSSize)size
{
	return size;
}

- (BOOL)hasPixelAtPoint:(NSPoint)point
{
	NSString *string = NSStringFromPoint(point);
	return [points containsObject:string];
}

- (void)togglePoint:(NSPoint)point
{
	if ([self hasPixelAtPoint:point]) {
		[self removePoint:point];
	} else {
		[self addPoint:point];
	}
}

- (void)addPoint:(NSPoint)point
{
	[points addObject:NSStringFromPoint(point)];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternChangedNotificationName object:self userInfo:nil];
	[pointsInBounds release];
	pointsInBounds = nil;
}

- (void)removePoint:(NSPoint)point
{
	[points removeObject:NSStringFromPoint(point)];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPatternChangedNotificationName object:self userInfo:nil];
	[pointsInBounds release];
	pointsInBounds = nil;
}


- (NSArray *)pointsInPattern
{
	if (pointsInBounds == nil) {
		pointsInBounds = [[NSMutableArray alloc] init];
		
		for (NSString *string in points)
		{
			NSPoint point = NSPointFromString(string);
			if (point.x >= 0 && point.y >= 0 && point.x < [self size].width && point.y < [self size].height) {
				[pointsInBounds addObject:string];
			}
		}
	}
	
	return pointsInBounds;
}

- (void)drawRect:(NSRect)rect
{
	NSPoint point;
	NSRect pixel;
	pixel.size = NSMakeSize(1,1);
	
	for (NSString *string in points)
	{
		point = NSPointFromString(string);
		pixel.origin = point;
		
		if (NSIntersectsRect(rect, pixel)) {
			NSRectFill(pixel);
		}
	}
}

@end
