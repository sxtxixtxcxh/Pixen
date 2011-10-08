//
//  InterpolatePoint.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "InterpolatePoint.h"

NSPoint InterpolatePointFromPointByPoint(NSPoint currentPoint, NSPoint initialPoint, NSPoint differencePoint)
{
	if(differencePoint.x == 0)
	{ 
		return NSMakePoint(currentPoint.x, currentPoint.y + ((differencePoint.y > 0) ? 1 : -1)); 
	}
	else if(differencePoint.y == 0) 
	{ 
		return NSMakePoint(currentPoint.x + ((differencePoint.x > 0) ? 1 : -1), currentPoint.y); 
	}
	else if(abs(differencePoint.x) < abs(differencePoint.y)) 
	{
		float y = currentPoint.y + ((differencePoint.y > 0) ? 1 : -1);
		return NSMakePoint(rintf((differencePoint.x/differencePoint.y)*(y-initialPoint.y) + initialPoint.x), y);
	} 
	else
	{
		float x = currentPoint.x + ((differencePoint.x > 0) ? 1 : -1);
		return NSMakePoint(x, rintf((differencePoint.y/differencePoint.x)*(x-initialPoint.x) + initialPoint.y));
	}
}
