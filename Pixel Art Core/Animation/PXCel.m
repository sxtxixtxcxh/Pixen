//
//  PXCel.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXCel.h"

#import "NSImage+Reps.h"
#import "PXAnimation.h"
#import "PXCanvas.h"
#import "PXCanvas_Drawing.h"
#import "PXCanvas_ImportingExporting.h"

@implementation PXCel

@synthesize canvas = _canvas, duration = _duration;
@dynamic size, info;

- (id)init
{
	if ( ! (self = [super init]))
		return nil;
	
	self.canvas = [[PXCanvas new] autorelease];
	self.duration = 1.0f;
	
	return self;
}

- (id)initWithCanvas:(PXCanvas *)initCanvas duration:(NSTimeInterval)initDuration
{
	if ( ! (self = [super init]))
		return nil;
	
	self.canvas = initCanvas;
	self.duration = initDuration;
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	return [self initWithCanvas:[coder decodeObjectForKey:@"canvas"]
					   duration:[coder decodeDoubleForKey:@"duration"]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.canvas forKey:@"canvas"];
	[coder encodeDouble:self.duration forKey:@"duration"];
}

- (id)copyWithZone:(NSZone *)zone
{
	PXCel *cel = [[PXCel alloc] initWithCanvas:[[self.canvas copyWithZone:zone] autorelease]
									  duration:self.duration];
	[[cel canvas] setGrid:[self.canvas grid]];
	
	return cel;
}

- (id)initWithImage:(NSImage *)image animation:(PXAnimation *)animation
{
	return [self initWithImage:image animation:animation atIndex:[animation countOfCels]];
}

- (id)initWithImage:(NSImage *)image animation:(PXAnimation *)animation atIndex:(NSUInteger)index
{
	if ( ! (self = [super init]))
		return nil;
	
	self.canvas = [[PXCanvas new] autorelease];
	[self.canvas setUndoManager:[animation undoManager]];
	[self.canvas replaceActiveLayerWithImage:image];
	
	self.duration = 1.0f;
	
	[animation insertObject:self inCelsAtIndex:index];
	
	return self;
}

- (void)dealloc
{
	[_canvas release];
	[super dealloc];
}

- (NSDictionary *)info
{
	return [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:self.duration] forKey:@"duration"];
}

- (void)setInfo:(NSDictionary *)info
{
	self.duration = [[info objectForKey:@"duration"] doubleValue];
}

- (void)setUndoManager:(NSUndoManager *)manager
{
	[self.canvas setUndoManager:manager];
}

- (NSSize)size
{
	return [self.canvas size];
}

- (void)setSize:(NSSize)size
{
	[self.canvas setSize:size];
}

- (void)setSize:(NSSize)size withOrigin:(NSPoint)origin backgroundColor:(PXColor)color
{
	[self.canvas setSize:size withOrigin:origin backgroundColor:color];
}

- (void)drawInRect:(NSRect)dst fromRect:(NSRect)src operation:(NSCompositingOperation)op fraction:(CGFloat)frac
{
	[self.canvas drawInRect:dst fromRect:src operation:op fraction:frac];
}

- (NSImage *)displayImage
{
	return [NSImage imageWithBitmapImageRep:[self.canvas imageRep]];
}

@end
