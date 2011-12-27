//
//  PXCanvas_ApplescriptAdditions.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXCanvas_ApplescriptAdditions.h"

#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"
#import "PXLayerController.h"
#import "PXNotifications.h"

@implementation PXCanvas (ApplescriptAdditions)

- (PXLayer *)layerNamed:(NSString *)aName
{
	for (PXLayer *current in layers)
	{
		if ([[current name] isEqualToString:aName])
		{
			return current;
		}
	}
	
	return nil;
}

- (id)handleGetColorScriptCommand:(id)command
{
	NSDictionary *arguments = [command evaluatedArguments];
	
	return [self colorAtPoint:NSMakePoint([[arguments objectForKey:@"atX"] intValue], [[arguments objectForKey:@"atY"] intValue])];
}

- (id)handleSetColorScriptCommand:(id)command
{
	NSDictionary *arguments = [command evaluatedArguments];
	NSArray *colorArray = [arguments objectForKey:@"toColor"];
	
	NSColor *color = [NSColor colorWithCalibratedRed:[[colorArray objectAtIndex:0] floatValue] / 65535
											   green:[[colorArray objectAtIndex:1] floatValue] / 65535
												blue:[[colorArray objectAtIndex:2] floatValue] / 65535
											   alpha:1.0f];
	
	NSPoint changedPoint = NSMakePoint([[arguments objectForKey:@"atX"] intValue], [[arguments objectForKey:@"atY"] intValue]);
	
	[self setColor:color atPoint:changedPoint];
	[self changedInRect:NSMakeRect(changedPoint.x, changedPoint.y, 1.0f, 1.0f)];
	
	return nil;
}

- (id)handleAddLayerScriptCommand:(id)command
{
	PXLayer *layer = [[PXLayer alloc] initWithName:[[command evaluatedArguments] objectForKey:@"layerName"]
											  size:[self size]];
	
	[self addLayer:layer];
	[layer release];
	
	return nil;
}

- (id)handleRemoveLayerScriptCommand:(id)command
{
	PXLayer *layer = [self layerNamed:[[command evaluatedArguments] objectForKey:@"layerName"]];
	
	if (layer)
	{
		[self removeLayer:layer];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:PXCanvasLayerSelectionDidChangeNotificationName
															object:self];
	}
	
	return nil;
}

- (id)handleMoveLayerScriptCommand:(id)command
{
	[self moveLayer:[layers objectAtIndex:[[[command evaluatedArguments] objectForKey:@"atIndex"] intValue]]
			toIndex:[[[command evaluatedArguments] objectForKey:@"toIndex"] intValue]];
	
	return nil;
}

- (void)setActiveLayerName:(NSString *)aName
{
	PXLayer *layer = [self layerNamed:aName];
	
	if (layer)
	{
		[self activateLayer:layer];
	}
}

- (int)height
{
	return (int) [self size].height;
}

- (void)setHeight:(int)height
{
	NSSize newSize = [self size];
	newSize.height = height;
	
	[self setSize:newSize];
}

- (int)width
{
	return (int) [self size].width;
}

- (void)setWidth:(int)width
{
	NSSize newSize = [self size];
	newSize.width = width;
	
	[self setSize:newSize];
}

@end
