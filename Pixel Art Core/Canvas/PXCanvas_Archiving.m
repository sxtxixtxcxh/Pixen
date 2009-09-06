//
//  PXCanvas_Archiving.m
//  Pixen
//
//  Created by Joe Osborn on 2005.07.31.
//  Copyright 2005 Open Sword Group. All rights reserved.
//

#import "PXCanvas_Archiving.h"
#import "PXCanvas_Backgrounds.h"
#import "PXCanvas_Selection.h"
#import "PXLayer.h"
#import "PXBackgroundConfig.h"
#ifndef __COCOA__
#include <math.h>
#import "PXNotifications.h"
#import "PXDefaults.h"
#endif

@implementation PXCanvas(Archiving)

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeInt:3 forKey:@"version"];
	[coder encodeObject:layers forKey:@"layers"];
	PXPalette_encodeWithCoder(palette, coder);

	[coder encodeObject:bgConfig forKey:@"bgConfig"];
	[coder encodeBool:wraps forKey:@"wraps"];
	[coder encodeObject:grid forKey:@"grid"];
	[coder encodeSize:previewSize forKey:@"previewSize"];
}

- initWithCoder:(NSCoder *)coder
{
	self = [self init];
	if (self == nil) {
		return nil;
	}
	int version = [coder decodeIntForKey:@"version"];
	if(version < 4)
	{
		palette = PXPalette_alloc();
		if(!PXPalette_initWithCoder(palette, coder))
		{
			PXPalette_release(palette);
		}		
		layers = [[coder decodeObjectForKey:@"layers"] retain];
		id enumerator = [layers objectEnumerator], current;
		while(current = [enumerator nextObject])
		{
			[current setCanvas:self];
			[current setPalette:palette];
		}
	
		bgConfig = [[coder decodeObjectForKey:@"bgConfig"] retain];
		if(!bgConfig)
		{
			bgConfig = [[PXBackgroundConfig alloc] initWithCoder:coder];
		}
		grid = [[coder decodeObjectForKey:@"grid"] retain];
		if(!grid)
		{
			grid = [[PXGrid alloc] initWithCoder:coder];
		}
		[self setPreviewSize:[coder decodeSizeForKey:@"previewSize"]];
		wraps = [coder decodeBoolForKey:@"wraps"];
	}
	canvasRect = NSMakeRect(0, 0, [self size].width, [self size].height);
	activeLayer = [layers lastObject];
	selectionMask = malloc([self selectionMaskSize]);
	memset(selectionMask, 0, [self selectionMaskSize]);	
	
	return self;
}

@end
