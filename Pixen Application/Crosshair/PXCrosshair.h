//
//  PXCrosshair.h
//  Pixen
//

#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>
@class NSColor;

@interface PXCrosshair : NSObject 
{
  @private
	NSPoint cursorPosition;
}

@property (nonatomic, assign) NSPoint cursorPosition;

- (void)drawRect:(NSRect)drawingRect withTool:tool tileOffset:(NSPoint)offset;
- (NSColor *) color;
- (BOOL)shouldDraw;

@end
