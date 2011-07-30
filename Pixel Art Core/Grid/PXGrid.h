//
//  PXGrid.h
//  Pixen
//

#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>
@class NSColor;



@interface PXGrid : NSObject <NSCopying, NSCoding>
{
  @private
	NSSize unitSize;
	NSColor *color;
	BOOL shouldDraw;
}

-(id) initWithUnitSize:(NSSize)unitSize
				 color:(NSColor *) color
			shouldDraw:(BOOL)shouldDraw;

- (NSSize)unitSize;
- (NSColor *)color;
- (BOOL)shouldDraw;

- (void)drawRect:(NSRect)rect;

- (void)setShouldDraw:(BOOL)shouldDraw;
- (void)setColor:(NSColor *)color;
- (void)setUnitSize:(NSSize)unitSize;

- (void)setDefaultParameters;

@end
