//
//  PXPattern.h
//  Pixen
//

#import <Foundation/Foundation.h>

@interface PXPattern : NSObject <NSCopying, NSCoding> {
  @private
	NSMutableSet *points;
	NSMutableArray *pointsInBounds;
	NSSize size;
}

- (NSSize)size;
- (NSArray *)pointsInPattern;

- (void)setSize:(NSSize)newSize;
- (void)setPoints:(NSMutableSet *)newPoints;

- (BOOL)hasPixelAtPoint:(NSPoint)point;
- (void)togglePoint:(NSPoint)point;
- (void)addPoint:(NSPoint)point;
- (void)removePoint:(NSPoint)point;

- (void)drawRect:(NSRect)rect;

@end
