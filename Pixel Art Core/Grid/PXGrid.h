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

@property (nonatomic, retain) NSColor *color;

-(id) initWithUnitSize:(NSSize)unitSize
				 color:(NSColor *) color
			shouldDraw:(BOOL)shouldDraw;

- (NSSize)unitSize;
- (BOOL)shouldDraw;

- (void)drawRect:(NSRect)rect;

- (void)setShouldDraw:(BOOL)shouldDraw;
- (void)setUnitSize:(NSSize)unitSize;

- (void)setDefaultParameters;

@end
