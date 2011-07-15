//
//  PXColorPickerColorWellCell.h
//  PXColorPicker
//
//  Created by Andy Matuschak on 7/7/05.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PXPaletteColorLayer : CALayer {
  @private
	int index;
	NSColor *color;
	NSControlSize controlSize;
	BOOL highlighted;
}

@property (nonatomic, assign) int index;
@property (nonatomic, retain) NSColor *color;
@property (nonatomic, assign) NSControlSize controlSize;
@property (nonatomic, assign) BOOL highlighted;

@end
