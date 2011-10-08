//
//  PXCanvas_Archiving.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXCanvas_Archiving.h"
#import "PXCanvas_Backgrounds.h"
#import "PXCanvas_Selection.h"
#import "PXLayer.h"
#import "PXBackgroundConfig.h"
#import "PXPalette.h"
#import "NSObject+AssociatedObjects.h"

@implementation PXCanvas(Archiving)

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeInt:3 forKey:@"version"];
	[coder encodeObject:layers forKey:@"layers"];
	
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
	if(version <= 4)
	{
		BOOL isIndexedImage = [coder containsValueForKey:@"palette"];
		PXPalette *palette = nil;
		if(isIndexedImage) {
			palette = [[PXPalette alloc] initWithCoder:coder];
			
			if (palette)
				[coder associateValue:palette withKey:@"palette"];
		}	
		
		if (layers) {
			[layers release];
			layers = nil;
		}
		
		layers = [[coder decodeObjectForKey:@"layers"] retain];
		for (PXLayer *current in layers)
		{
			[current setCanvas:self];
		}
		
		if(isIndexedImage) {
			[coder associateValue:nil withKey:@"palette"];
			if(palette) {
				[palette release];
			}
		}
		
		if (bgConfig) {
			[bgConfig release];
			bgConfig = nil;
		}
		
		bgConfig = [[coder decodeObjectForKey:@"bgConfig"] retain];
		if(!bgConfig)
		{
			bgConfig = [[PXBackgroundConfig alloc] initWithCoder:coder];
		}
		
		if (grid) {
			[grid release];
			grid = nil;
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
	
	[self refreshWholePalette];
	
	return self;
}

@end
