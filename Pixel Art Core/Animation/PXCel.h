//
//  PXCel.h
//  Pixen
//
//  Created by Joe Osborn on 2005.08.09.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXPalette.h"
@class PXCanvas, PXAnimation;
@interface PXCel : NSObject <NSCoding, NSCopying> {
	PXCanvas *canvas;
	NSTimeInterval duration;
}
- initWithImage:(NSImage *)image animation:(PXAnimation *)animation atIndex:(int)index;
- initWithImage:(NSImage *)image animation:(PXAnimation *)animation;
- (PXCanvas *)canvas;
- (void)setCanvas:(PXCanvas *)canv;
- (PXPalette *)palette;
- (void)setPalette:(PXPalette *)pal;
- (void)setPalette:(PXPalette *)pal recache:(BOOL)recache;
- (NSSize)size;
- (void)setSize:(NSSize)size;
- (void)setSize:(NSSize)aSize withOrigin:(NSPoint)origin backgroundColor:(NSColor *)bgcolor;
- (void)setUndoManager:man;
- (NSTimeInterval) duration;
- (void)setDuration:(NSTimeInterval)duration;
- (NSDictionary *)info;
- (void)setInfo:(NSDictionary *)info;
- (NSImage *)displayImage;
@end
