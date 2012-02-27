//
//  PXPattern.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

@interface PXPattern : NSObject < NSCopying, NSCoding >
{
  @private
	NSMutableSet *_points;
	NSMutableArray *_pointsInBounds;
	NSSize _size;
}

@property (nonatomic, assign) NSSize size;

- (NSString *)sizeString;
- (NSImage *)image;

- (NSArray *)pointsInPattern;
- (void)setPoints:(NSMutableSet *)newPoints;

- (BOOL)hasPixelAtPoint:(NSPoint)point;
- (void)togglePoint:(NSPoint)point;
- (void)addPoint:(NSPoint)point;
- (void)removePoint:(NSPoint)point;

- (void)drawRect:(NSRect)rect;

@end
