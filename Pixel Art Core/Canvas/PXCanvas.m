//  PXCanvas.m
//  Pixen
//
// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Joe Osborn on Sat Sep 13 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import "PXCanvas.h"
#import "PXCanvas_Modifying.h"
#import "PXCanvas_Drawing.h"
#import "PXCanvas_Backgrounds.h"
#import "PXCanvas_Selection.h"
#import "PXCanvas_Layers.h"
#import "PXLayer.h"
#import "PXBackgroundConfig.h"
#ifndef __COCOA__
#include <math.h>
#import "PXNotifications.h"
#import "PXDefaults.h"
#endif

@implementation PXCanvas

-(id)copyWithZone:(NSZone*) zone
{
	return [[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]] retain];
}

- (id)_rawInit
{
	if (![super init]) return nil;
	return self;
}

- (void)recacheSize
{
	canvasRect = NSMakeRect(0, 0, [self size].width, [self size].height);
}

- (id)duplicateWithinAnimation
{
	PXCanvas *canvas = [[[self class] alloc] _rawInit];
	[canvas setPalette:[self palette]];
	[canvas setLayers:[[self layers] deepMutableCopy]];
	[canvas recacheSize];
	[canvas setMainBackground:[self mainBackground]];
	[canvas setAlternateBackground:[self alternateBackground]];
	[canvas setMainPreviewBackground:[self mainPreviewBackground]];
	[canvas setAlternatePreviewBackground:[self alternatePreviewBackground]];
	[canvas setGrid:grid];
	[canvas setPreviewSize:[self previewSize]];
	[canvas setWraps:[self wraps]];
	[canvas reallocateSelection];
	[canvas setUndoManager:[self undoManager]];
	return canvas;
}

- (id)initWithoutBackgroundColor
{
	if (![super init]) return nil;
	layers = [[NSMutableArray alloc] initWithCapacity:23];
	palette = PXPalette_initWithoutBackgroundColor(PXPalette_alloc());
	grid = [[PXGrid alloc] init];
	bgConfig = [[PXBackgroundConfig alloc] init];
	wraps = NO;
	return self;
}

- (id)init
{
	if (![self initWithoutBackgroundColor]) { return nil; }
	PXPalette_addBackgroundColor(palette);
	return self;
}

- (void)dealloc
{
	if (selectionMask)
	{
		free(selectionMask);
	}
	
	[layers release];
	PXPalette_release(palette);
	[bgConfig release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (PXPalette *)palette
{
	return palette;
}

- (void)setPalette:(PXPalette *)pal recache:(BOOL)recache
{
	PXPalette_retain(pal);
	PXPalette_release(palette);
	palette = pal;
	id enumerator = [layers objectEnumerator], current;
	while(current = [enumerator nextObject])
	{
		[current setPalette:palette recache:recache];
	}
}

- (void)setPalette:(PXPalette *)pal
{
	[self setPalette:pal recache:YES];
}

- (PXGrid *)grid 
{
	return grid;
}

- (void)setGrid:(PXGrid *)g
{
	PXGrid *oldGrid = grid;
	grid = [g retain];
	[oldGrid autorelease];
}

- (void)setUndoManager:(NSUndoManager *)manager
{
	undoManager = manager;
	palette->undoManager = manager;
	[undoManager setGroupsByEvent:NO];
//	[layers setValue:manager forKey:@"undoManager"];
}

- (NSUndoManager *)undoManager
{
	return undoManager;
}

- (NSSize)size
{
	if([layers count] > 0) {
		PXLayer *firstLayer = [layers objectAtIndex:0];
		return [firstLayer size];
	}
	
	return NSZeroSize;
}

- (void)updatePreviewSize
{
	canvasRect = NSMakeRect(0, 0, [self size].width, [self size].height);  //Cached because [self size] and NSMakeRect slow things down when containsPoint is called a bunch
	NSSize aSize = [self size];
	if (aSize.width > 256 || aSize.height > 256)
	{
		if (aSize.width > aSize.height)
		{
			previewSize.width = 256;
			previewSize.height = aSize.height * (256 / aSize.width);
		}
		else
		{
			previewSize.height = 256;
			previewSize.width = aSize.width * (256 / aSize.height);
		}
	}
	else
	{	
		previewSize = [self size];
	}
	[self layersChanged];
}

- (void)setSize:(NSSize)aSize 
	 withOrigin:(NSPoint)origin
backgroundColor:(NSColor *)color
{
	unsigned newMaskLength = sizeof(BOOL) * aSize.width * aSize.height;
	PXSelectionMask newMask = calloc(aSize.width * aSize.height, sizeof(BOOL));
	/* we'll just toss the selection when the canvas resizes.  that's not too heinous.
	int i, j;
	NSSize oldSize = [self size];
	int origin_x=origin.x, origin_y=origin.y; // pre-converting to integer
	for (j = 0; j < aSize.height; j++)
	{
		int src_y = (oldSize.height - (j - origin_y) - 1) * oldSize.width;
		int dst_y = (aSize.height - j - 1) * aSize.width;
		for (i = 0; i < aSize.width; i++)
		{
			if ((j - origin_y) < oldSize.height && (j - origin_y) >= 0 && (i - origin_x) < oldSize.width && (i - origin_x) >= 0) {
				newMask[dst_y + i] = selectionMask[src_y + i - origin_x];
			}
		}
	}*/
	if([layers count] > 0)
	{
		[self beginUndoGrouping]; {
			id newData = [NSData dataWithBytes:newMask length:newMaskLength];
			id oldData = [NSData dataWithBytes:selectionMask length:[self selectionMaskSize]];
			
			[self setLayersNoResize:[[layers deepMutableCopy] autorelease] fromLayers:layers];
			id enumerator = [layers objectEnumerator];
			id current;
			while(current = [enumerator nextObject])
			{
				[current setSize:aSize withOrigin:origin backgroundColor:color];
			}
			[self setMaskData:newData withOldMaskData:oldData];
			NSLog(@"Mask data updated - copied %@", [[layers lastObject] name]);
			free(newMask);
		} [self endUndoGrouping:NSLocalizedString(@"Change Canvas Size", @"Change Canvas Size")];
	}
	else 
	{
		unsigned int ind = PXPalette_indexOfColorAddingIfNotPresent(palette, color);
		[self insertLayer:[[[PXLayer alloc] initWithName:NSLocalizedString(@"Main Layer", @"Main Layer") size:aSize fillWithColorIndex:ind] autorelease] atIndex:0];
		[[layers lastObject] setPalette:palette];
		[self activateLayer:[layers objectAtIndex:0]];
		[[self undoManager] removeAllActions];
		selectionMask = newMask;
		[self updateSelectionSwitch];
	}
	[[self layers] makeObjectsPerformSelector:@selector(recache)];
	[[NSNotificationCenter defaultCenter] postNotificationName:PXSelectionMaskChangedNotificationName object:self];
	selectedRect = NSZeroRect;
	[self updatePreviewSize];
}

- (void)setSize:(NSSize)aSize
{
	NSColor *color = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0];
	
	[self setSize:aSize
	   withOrigin:NSZeroPoint 
  backgroundColor:color];
}

- (NSSize)previewSize
{
	if (previewSize.width == 0 && previewSize.height == 0)
		return [self size];
	
	return previewSize;
}

- (void)setPreviewSize:(NSSize)aSize
{
	previewSize = aSize;
}

- (void)beginUndoGrouping
{
	[[self undoManager] beginUndoGrouping];
}

- (void)endUndoGrouping:(NSString *)action
{
	[[self undoManager] setActionName:action];
	[self endUndoGrouping];
}

- (void)endUndoGrouping
{
	[[self undoManager] endUndoGrouping];
}

- (unsigned)eraseColorIndex
{
	return PXPalette_indexOfEraseColorAddingIfNotPresent([self palette]);
//	return PXPalette_indexOfColorAddingIfNotPresent([self palette], [NSColor clearColor]);
//friendly version, sux for jpgs etc - we really need a 'background layer'
//	return ([self activeLayer] == [[self layers] objectAtIndex:0]) ? 0 : PXPalette_indexOfColorAddingIfNotPresent([self palette], [NSColor clearColor]);
}

@end
