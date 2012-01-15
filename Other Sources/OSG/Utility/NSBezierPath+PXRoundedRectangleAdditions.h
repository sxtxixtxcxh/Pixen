//
//  NSBezierPath+PXRoundedRectangleAdditions.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

typedef enum _OSCornerTypes
{
	OSTopLeftCorner = 1,
	OSBottomLeftCorner = 2,
	OSTopRightCorner = 4,
	OSBottomRightCorner = 8
} OSCornerType;

@interface NSBezierPath (PXRoundedRectangle)

+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)aRect cornerRadius:(CGFloat)radius;
+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)aRect cornerRadius:(CGFloat)radius inCorners:(OSCornerType)corners;

@end
