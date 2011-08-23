//
//  PXLayer.m
//  QLPlugin
//
//  Created by Matt Rajca on 7/16/11.
//  Copyright 2011 Matt Rajca. All rights reserved.
//

#import "PXLayer.h"
#import "PXPalette.h"
#import "NSObject+AssociatedObjects.h"

@implementation PXLayer

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	if (self) {
		image = PXImage_initWithCoder(PXImage_alloc(), coder, (PXPalette *)[coder associatedValueForKey:@"palette"]);
		
		visible = [coder containsValueForKey:@"visible"] ? [coder decodeBoolForKey:@"visible"] : YES;
		opacity = [coder decodeObjectForKey:@"opacity"] ? [[coder decodeObjectForKey:@"opacity"] doubleValue] : 100;
	}
	return self;
}

- (void)dealloc
{
	PXImage_release(image);
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder { }

- (void)draw
{
	if (!visible)
		return;
	
	NSRect rect = NSMakeRect(0.0f, 0.0f, [self size].width, [self size].height);
	PXImage_drawInRectFromRectWithOperationFraction(image, rect, rect, NSCompositeSourceOver, opacity);
}

- (NSSize)size
{
	if (image == NULL)
		return NSZeroSize;
	
	return NSMakeSize(image->width, image->height);
}

@end
