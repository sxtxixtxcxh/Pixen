//
//  PXCanvas.m
//  QLPlugin
//
//  Created by Matt Rajca on 7/16/11.
//  Copyright 2011-2012 Matt Rajca. All rights reserved.
//

#import "PXCanvas.h"
#import "PXPalette.h"
#import "PXLayer.h"
#import "NSObject+AssociatedObjects.h"

@implementation PXCanvas

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	if (self) {
		int version = [coder decodeIntForKey:@"version"];
		if (version <= 4) {
			BOOL isIndexedImage = [coder containsValueForKey:@"palette"];
			PXPalette *palette = NULL;
			if(isIndexedImage) {
				palette = [[PXPalette alloc] initWithCoder:coder];
				
				if (!palette)
					[palette release];
				
				[coder associateValue:palette withKey:@"palette"];
			}	
			layers = [[coder decodeObjectForKey:@"layers"] retain];
			if(isIndexedImage) {
				[coder associateValue:nil withKey:@"palette"];
				if(palette) {
					[palette release];
				}
			}
    }
	}
	return self;
}

- (void)dealloc
{
	[layers release];
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder { }

- (void)draw
{
	for (PXLayer *layer in layers) {
		[layer draw];
	}
}

- (NSSize)size
{
	if ([layers count] > 0) {
		PXLayer *firstLayer = [layers objectAtIndex:0];
		return [firstLayer size];
	}
	
	return NSZeroSize;
}

@end
