//
//  PXPaletteColorLayer.h
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

@interface PXPaletteColorLayer : CALayer
{
  @private
	NSUInteger _index;
	NSColor *_color;
	NSControlSize _controlSize;
	BOOL _highlighted;
}

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, retain) NSColor *color;
@property (nonatomic, assign) NSControlSize controlSize;
@property (nonatomic, assign) BOOL highlighted;

@end
