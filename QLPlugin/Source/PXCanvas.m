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
			
			if (isIndexedImage) {
				PXPalette *palette = [[PXPalette alloc] initWithCoder:coder];
				[coder associateValue:palette withKey:@"palette"];
			}
			
			layers = [coder decodeObjectForKey:@"layers"];
			
			if (isIndexedImage) {
				[coder associateValue:nil withKey:@"palette"];
			}
		}
	}
	return self;
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
