//
//  PXNSImageView.h
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

@interface PXNSImageView : NSImageView
{
  @private
	NSRect functionalRect;
	float scaleFactor;
	NSShadow *shadow;
}

- (NSRect)functionalRect;
- (void)setFunctionalRect:(NSRect)fr;
- (NSSize)scaledSizeForImage:(NSImage *)image;

@end
