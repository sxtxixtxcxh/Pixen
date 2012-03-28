//
//  PXCanvas_ApplescriptAdditions.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCanvas_ApplescriptAdditions.h"

#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"

@implementation PXCanvas (ApplescriptAdditions)

- (id)handleAddLayerScriptCommand:(id)command
{
	NSString *name = [[command evaluatedArguments] objectForKey:@"layerName"];
	
	PXLayer *layer = [[PXLayer alloc] initWithName:name size:[self size]];
	
	[self addLayer:layer];
	[layer release];
	
	return nil;
}

- (id)handleGetColorScriptCommand:(id)command
{
	NSDictionary *arguments = [command evaluatedArguments];
	int x = [[arguments objectForKey:@"atX"] intValue];
	int y = [[arguments objectForKey:@"atY"] intValue];
	
	return PXColorToNSColor([self colorAtPoint:NSMakePoint(x, y)]);
}

- (id)handleMoveLayerScriptCommand:(id)command
{
	int atIndex = [[[command evaluatedArguments] objectForKey:@"atIndex"] intValue];
	int toIndex = [[[command evaluatedArguments] objectForKey:@"toIndex"] intValue];
	
	if (atIndex < 0)
		atIndex = 0;
	
	if (toIndex < 0)
		toIndex = 0;
	
	[self moveLayerAtIndex:atIndex toIndex:toIndex];
	
	return nil;
}

- (id)handleRemoveLayerScriptCommand:(id)command
{
	NSString *name = [[command evaluatedArguments] objectForKey:@"layerName"];
	PXLayer *layer = [self layerNamed:name];
	
	if (layer && [[self layers] count] > 1)
		[self removeLayer:layer];
	
	return nil;
}

- (id)handleSetColorScriptCommand:(id)command
{
	NSDictionary *arguments = [command evaluatedArguments];
	PXColor color = PXColorFromNSColor([arguments objectForKey:@"toColor"]);
	int x = [[arguments objectForKey:@"atX"] intValue];
	int y = [[arguments objectForKey:@"atY"] intValue];
	
	NSPoint changedPoint = NSMakePoint(x, y);
	
	[self beginColorUpdates];
	[self setColor:color atPoint:changedPoint];
	[self changedInRect:NSMakeRect(changedPoint.x, changedPoint.y, 1.0f, 1.0f)];
	[self endColorUpdates];
	
	return nil;
}

- (NSString *)activeLayerName
{
	return [self activeLayer].name;
}

- (void)setActiveLayerName:(NSString *)name
{
	PXLayer *layer = [self layerNamed:name];
	
	if (layer)
		[self activateLayer:layer];
}

- (int)width
{
	return (int) [self size].width;
}

- (int)height
{
	return (int) [self size].height;
}

@end
