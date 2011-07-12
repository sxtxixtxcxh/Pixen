//
//  PXColorPickerColorWellCell.h
//  PXColorPicker
//
//  Created by Andy Matuschak on 7/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PXColorPickerColorWellCell : NSCell {
	int index;
	NSColor *color;
	NSImage *smallNewColorImage, *bigNewColorImage;
}

- (int)index;
- (void)setIndex:(int)newIndex;
- (NSColor *)color;
- (void)setColor:(NSColor *)newColor;

@end
