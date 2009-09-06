//
//  PXPalette.m
//  Pixen-XCode

// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy

// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation 
// the rights  to use,copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom
//  the Software is  furnished to do so, subject to the following conditions:

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

#import "PXPalette.h"
#import "PathUtilities.h"
#import "NSColor+PXPaletteAdditions.h"

@interface NSString(CompareNumeric)
- (NSComparisonResult)compareNumeric:other;
@end

@implementation NSString(CompareNumeric)

- (NSComparisonResult)compareNumeric:other
{
	return [self compare:other options:NSNumericSearch];
}

@end

//this is a class because NSUndoManager likes to play with objects.
@interface PXPaletteUndo : NSObject {}
+ (void)palette:(PXPalette *)pal setLocked:(BOOL)lock;
+ (void)palette:(PXPalette *)pal postponeNotifications:(BOOL)post;
+ (void)palette:(PXPalette *)pal addColor:(NSColor *)col;
+ (void)palette:(PXPalette *)pal removeColorAtIndex:(unsigned)ind;
+ (void)palette:(PXPalette *)pal swapColorAtIndex:(unsigned)src withColorAtIndex:(unsigned)dst;
+ (void)palette:(PXPalette *)pal moveColorAtIndex:(unsigned)src toIndex:(unsigned)dst adjustIndices:(BOOL)adjust;
+ (void)palette:(PXPalette *)pal setColor:(NSColor *)col atIndex:(unsigned)index;
@end

@implementation PXPaletteUndo
+ (void)palette:(PXPalette *)pal setLocked:(BOOL)lock
{
	if(lock)
	{
		PXPalette_lock(pal);
	}
	else
	{
		PXPalette_unlock(pal);
	}
}
+ (void)palette:(PXPalette *)pal postponeNotifications:(BOOL)post
{
	PXPalette_postponeNotifications(pal,post);
}
+ (void)palette:(PXPalette *)pal addColor:(NSColor *)col
{
	PXPalette_addColor(pal, [col autorelease]);
}
+ (void)palette:(PXPalette *)pal removeColorAtIndex:(unsigned)ind
{
	PXPalette_removeColorAtIndex(pal, ind);
}
+ (void)palette:(PXPalette *)pal swapColorAtIndex:(unsigned)src withColorAtIndex:(unsigned)dst
{
	PXPalette_swapColorsAtIndex(pal,src,dst);
}
+ (void)palette:(PXPalette *)pal moveColorAtIndex:(unsigned)src toIndex:(unsigned)dst adjustIndices:(BOOL)adjust
{
	PXPalette_moveColorAtIndexToIndex(pal,src,dst,adjust);
}
+ (void)palette:(PXPalette *)pal setColor:(NSColor *)col atIndex:(unsigned)index
{
	PXPalette_setColorAtIndex(pal,col,index);
}
@end

static id paletteUndoer = nil;

PXColorBucket *PXColorBucket_alloc()
{
	return (PXColorBucket *)calloc(1, sizeof(PXColorBucket));
}

PXColorBucket *PXColorBucket_init(PXColorBucket *self, NSColor *color, unsigned int index)
{
	self->next = NULL;
	self->color = [color retain];
	self->index = index;
	return self;
}

void PXColorBucket_dealloc(PXColorBucket *self)
{
	if (self->next != NULL) {
		PXColorBucket_dealloc(self->next);
	}
	[self->color release];
	free(self);
}

/////////////////////// BUCKET METHODS ///////////////////////

void PXPalette_insertColorBucket(PXPalette *self, PXColorBucket *bucket)
{
	unsigned int hash = [bucket->color paletteHash];
	bucket->next = self->reverseHashTable[hash];
	self->reverseHashTable[hash] = bucket;
}

PXColorBucket *PXPalette_bucketForColor(PXPalette *self, NSColor *color)
{
	unsigned int hash = [color paletteHash];
	PXColorBucket *bucket = self->reverseHashTable[hash];
	while (bucket != NULL && ![color isEqual:bucket->color]) {
		bucket = bucket->next;
	}
	return bucket;
}

void PXPalette_removeBucketForColor(PXPalette *self, NSColor *color)
{
	unsigned int hash = [color paletteHash];
	PXColorBucket *bucket = self->reverseHashTable[hash];
	PXColorBucket *prevBucket = NULL;
	while (bucket != NULL && ![bucket->color isEqual:color]) {
		prevBucket = bucket;
		bucket = bucket->next;
	}
	if (bucket != NULL) {
		if (prevBucket == NULL) {
			self->reverseHashTable[hash] = bucket->next;
		} else {
			prevBucket->next = bucket->next;
		}
		bucket->next = NULL;
		PXColorBucket_dealloc(bucket);
	}
}

//////////////////////////////////////////////////////////////

static PXPalette **systemPalettes = NULL;
static unsigned int systemPalettesCount = 0;

static PXPalette **userPalettes = NULL;
static unsigned int userPalettesCount = 0;

NSDictionary *PXPalette_dictForArchiving(PXPalette *self)
{
	NSMutableDictionary *paletteDict = [NSMutableDictionary dictionaryWithCapacity:4];
	[paletteDict setObject:[NSNumber numberWithInt:self->size] forKey:@"size"];
	// can't just copy bytes of the array of colors because they're pointers.
	int i;
	NSMutableArray *tempArray= [[[NSMutableArray alloc] init] autorelease];
	for (i = 0; i < self->colorCount; i++)
	{
		[tempArray addObject:[[self->colors[i] copy] autorelease]];
	}
	[paletteDict setObject:[NSNumber numberWithBool:self->locked] forKey:@"locked"];
	[paletteDict setObject:self->name forKey:@"name"];
	[paletteDict setObject:tempArray forKey:@"colors"];
	return paletteDict;
}

void PXPalette_saveChanges(PXPalette *self)
{
	if(self->canSave)
	{
		NSString *path = [[GetPixenPaletteDirectory() stringByAppendingPathComponent:self->name] stringByAppendingPathExtension:PXPaletteSuffix];
		id dict = PXPalette_dictForArchiving(self);
		[NSKeyedArchiver archiveRootObject:dict toFile:path];
	}
}

PXPalette *PXPalette_initWithDictionary(PXPalette *self, NSDictionary *dict)
{
	PXPalette_initWithoutBackgroundColor(self);
	PXPalette_postponeNotificationsSilently(self,YES,YES);
	PXPalette_setName(self, [dict objectForKey:@"name"]);
	PXPalette_resize(self, [[dict objectForKey:@"size"] intValue]);
	id array = [dict objectForKey:@"colors"];
	id enumerator = [array objectEnumerator], current;
	while (current = [enumerator nextObject])
	{
		PXPalette_addColor(self, current);
	}
	self->locked = [[dict objectForKey:@"locked"] boolValue];
	PXPalette_postponeNotificationsSilently(self,NO,YES);
	return self;
}

BOOL PXPalette_isDocumentPalette(PXPalette *self)
{
	if (self->canSave) { return NO; } // Must be a user palette.
	// Let's see if it's a system palette.
	int systemCount = PXPalette_getSystemPalettes(NULL,0);
	PXPalette **systemPalettes = calloc(systemCount, sizeof(PXPalette *));
	PXPalette_getSystemPalettes(systemPalettes, 0);
	int i;
	for (i = 0; i < systemCount; i++)
	{
		if (self == systemPalettes[i])
		{
			free(systemPalettes);
			return NO;
		}
	}
	free(systemPalettes);
	return YES;
}

NSArray *CreateGrayList()
{
	float rgb = 0;
	float alpha = 1;
	NSMutableArray *grays = [NSMutableArray arrayWithCapacity:256];
	NSColor *color;
	int i = 0;
	//Maybe we can factor these into a series of function calls?
	for (i=0; i<64; i++) {
		rgb = (float)i / 64.0;
		color = [NSColor colorWithCalibratedRed:rgb green:rgb blue:rgb alpha:alpha];
		[grays addObject:color];
	}
	rgb = 0;
	for (i=0; i<64; i++) {
		alpha = log2(64 - i) * 0.1667;
		color = [NSColor colorWithCalibratedRed:rgb green:rgb blue:rgb alpha:alpha];
		[grays addObject:color];
	}
	rgb = .5;
	for (i=0; i<64; i++) {
		alpha = log2(64 - i) * 0.1667;
		color = [NSColor colorWithCalibratedRed:rgb green:rgb blue:rgb alpha:alpha];
		[grays addObject:color];
	}
	rgb = 1;
	for (i=0; i<64; i++) {
		alpha = log2(64 - i) * 0.1667;
		color = [NSColor colorWithCalibratedRed:rgb green:rgb blue:rgb alpha:alpha];
		[grays addObject:color];
	}
	return grays;
}

unsigned int PXPalette_getSystemPalettes(PXPalette **pals, unsigned initialIndex)
{
	NSArray *lists = [NSColorList availableColorLists];
	int newCount = [lists count] + 1;
	if(pals == NULL) { return newCount; }
	if(systemPalettes == NULL)
	{
		systemPalettes = calloc(newCount, sizeof(PXPalette *));
	}
	if(newCount != systemPalettesCount)
	{
		int i;
		for(i = 0; i < systemPalettesCount; i++)
		{
			PXPalette_release(systemPalettes[i]);
		}
		free(systemPalettes);
		systemPalettes = calloc(newCount, sizeof(PXPalette *));
		for(i = 0; i < [lists count]; i++)
		{
			NSEnumerator *keyEnumerator;
			NSColorList *current = [lists objectAtIndex:i];
			NSString *currentKey;
			PXPalette *palette = PXPalette_alloc();
			PXPalette_initWithoutBackgroundColor(palette);
			PXPalette_postponeNotificationsSilently(palette,YES,YES);
			PXPalette_setName(palette, [current name]);
			keyEnumerator = [[current allKeys] objectEnumerator];
			while((currentKey = [keyEnumerator nextObject]))
			{
				PXPalette_addColor(palette,[current colorWithKey:currentKey]);
			}
			PXPalette_postponeNotificationsSilently(palette,NO,YES);
			palette->isSystemPalette = YES;
			palette->canSave = NO;
			systemPalettes[i] = palette;
		}
		NSMutableArray *grays = [NSMutableArray arrayWithArray:CreateGrayList()];
		PXPalette *palette = PXPalette_alloc();
		PXPalette_initWithoutBackgroundColor(palette);
		PXPalette_postponeNotificationsSilently(palette,YES,YES);
#ifdef COCOA
		PXPalette_setName(palette, NSLocalizedString(@"GRAYSCALE", @"Grayscale"));
#else
//#warning GNUSTEP TODO -- don't care
		PXPalette_setName(palette, @"Grayscale");
#endif
		palette->isSystemPalette = YES;
		palette->canSave = NO;
		id enumerator = [grays objectEnumerator], current;
		while(current = [enumerator nextObject])
		{
			PXPalette_addColor(palette, current);
		}
		PXPalette_postponeNotificationsSilently(palette,NO,YES);
		systemPalettes[[lists count]] = palette;
		systemPalettesCount = newCount;
	}
	int i;
	for(i = initialIndex; i < (initialIndex + systemPalettesCount); i++)
	{
		pals[i] = systemPalettes[i - initialIndex];
	}
	return systemPalettesCount;
}

unsigned int PXPalette_getUserPalettes(PXPalette **pals, unsigned initialIndex)
{
#warning this code will leak or worse(probably just leak) if palettes are removed at runtime.
	NSMutableArray *paths = [NSMutableArray array];
	id enumerator = [[NSFileManager defaultManager] enumeratorAtPath:GetPixenPaletteDirectory()], current;
	while(current = [enumerator nextObject])
	{
		if([[current pathExtension] isEqual:PXPaletteSuffix])
		{
			//removing path extension so it will sort correctly.
			[paths addObject:[current stringByDeletingPathExtension]];
		}
	}
	[paths sortUsingSelector:@selector(compareNumeric:)];
	int newCount = [paths count];
	if(pals == NULL) { return newCount; }
	if(userPalettes == NULL)
	{
		userPalettes = calloc(newCount, sizeof(PXPalette *));
	}
	if(newCount != userPalettesCount)
	{
		int i;
		for(i = 0; i < [paths count]; i++)
		{
			NSString *path = [[GetPixenPaletteDirectory() stringByAppendingPathComponent:[paths objectAtIndex:i]] stringByAppendingPathExtension:PXPaletteSuffix];
			id object = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
			PXPalette *palette = NULL;
			palette = PXPalette_initWithDictionary(PXPalette_alloc(), object);
			palette->isSystemPalette = NO;
			palette->canSave = YES;
			palette->locked = NO;
			userPalettes[i] = palette;
		}
		userPalettesCount = newCount;
	}
	int i;
	for(i = initialIndex; i < (initialIndex + userPalettesCount); i++)
	{
		pals[i] = userPalettes[i - initialIndex];
	}
	return userPalettesCount;
}

PXPalette *PXPalette_alloc()
{
	PXPalette *palette = (PXPalette *)calloc(1, sizeof(PXPalette));
	palette->retainCount = 1;
	if(!paletteUndoer)
	{
		paletteUndoer = [PXPaletteUndo class];
	}
	return palette;
}

void PXPalette_dealloc(PXPalette *self)
{
	self->undoManager = nil;
	PXPalette_postponeNotificationsSilently(self,YES,YES);
	int i;
	for (i=0; i<65536; i++) {
		if (self->reverseHashTable[i] != NULL) {
			PXColorBucket_dealloc(self->reverseHashTable[i]);
		}
	}
	for(i = 0; i < self->size; i++)
	{
		if(self->colors[i])
		{
			[self->colors[i] release];
		}
	}
	free(self->colors);
	free(self->reverseHashTable);
	self->colors = nil;
	self->reverseHashTable = nil;
	[self->name release];
	self->name = nil;
	free(self);
}

PXPalette *PXPalette_initWithoutBackgroundColor(PXPalette *self)
{
	self->canSave = NO;
	self->isSystemPalette = NO;
	self->size = 0;
	self->colorCount = 0;
	self->undoManager = nil;
	self->reverseHashTable = (PXColorBucket **)calloc(65536, sizeof(PXColorBucket *));
	self->locked = NO;
	self->name = @"";
	return self;
}

PXPalette *PXPalette_init(PXPalette *self)
{
	PXPalette_initWithoutBackgroundColor(self);
	PXPalette_addBackgroundColor(self);
	return self;
}

PXPalette *PXPalette_copy(PXPalette *self)
{
	PXPalette *newPalette = PXPalette_initWithoutBackgroundColor(PXPalette_alloc());
	newPalette->undoManager = self->undoManager;
	newPalette->name = [self->name copy];
	PXPalette_postponeNotificationsSilently(newPalette,YES,YES);
	int i;
	for (i = 0; i < self->colorCount; i++) {
		PXPalette_addColor(newPalette, self->colors[i]);
	}
	PXPalette_postponeNotificationsSilently(self,NO,YES);
	newPalette->locked = self->locked;
	return newPalette;
}

void PXPalette_encodeWithCoder(PXPalette *self, NSCoder *coder)
{
	[coder encodeObject:PXPalette_dictForArchiving(self) forKey:@"palette"];
	[coder encodeObject:[NSNumber numberWithInt:3] forKey:@"paletteVersion"];
}

PXPalette *PXPalette_initWithCoder(PXPalette *self, NSCoder *coder)
{
	return PXPalette_initWithDictionary(self, [coder decodeObjectForKey:@"palette"]);
}

PXPalette *PXPalette_retain(PXPalette *self)
{
	if(!self)
	{
		return NULL;
	}
	self->retainCount++;
	return self;
}

PXPalette *PXPalette_release(PXPalette *self)
{
	if(!self) { return NULL; }
	self->retainCount--;
	if (self->retainCount <= 0) {
		PXPalette_dealloc(self);
	}
	return self;
}

// special for adding, so we don't build a userInfo dictionary for each pixel when loading a full-color image
void PXPalette_postAddedNotification(PXPalette *self)
{
	if (self->postponingNotifications) {
		self->postedNotificationWhilePostponing = YES;
		return;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPaletteChangedNotificationName object:[NSValue valueWithPointer:(void *)self] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:PXPaletteAddedColorNotificationName, PXSubNotificationNameKey, [NSNumber numberWithUnsignedInt:self->colorCount - 1], PXChangedIndexKey, nil]];
}

void PXPalette_insertColorAtIndex(PXPalette *self, NSColor *color, unsigned index, BOOL adjust)
{
	PXPalette_addColor(self, color);
	PXPalette_moveColorAtIndexToIndex(self,self->colorCount-1,index,adjust);
}

void PXPalette_postChangedNotification(PXPalette *self, NSDictionary *userInfo)
{
	if (self->postponingNotifications) {
		self->postedNotificationWhilePostponing = YES;
		return;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPaletteChangedNotificationName object:[NSValue valueWithPointer:(void *)self] userInfo:userInfo];
}

void PXPalette_removeAlphaComponents(PXPalette *self)
{
	PXPalette_postponeNotifications(self,YES);
	int i;
	for(i = 0; i < self->colorCount; i++)
	{
		NSColor *color = [[PXPalette_colorAtIndex(self, i) retain] autorelease];
		if([color alphaComponent] == 0 || [color alphaComponent] == 1) { continue; }
		PXPalette_setColorAtIndex(self,[color colorWithAlphaComponent:1],i);
	}
	PXPalette_postponeNotifications(self,NO);
}

void PXPalette_postponeNotificationsSilently(PXPalette *self, BOOL postpone, BOOL silent)
{
	if (!silent && self->postponingNotifications && !postpone && self->postedNotificationWhilePostponing) {
		[[NSNotificationCenter defaultCenter] postNotificationName:PXPaletteChangedNotificationName object:[NSValue valueWithPointer:(void *)self] userInfo:nil];
	}
	self->postedNotificationWhilePostponing = NO;
	self->postponingNotifications = postpone;	
}

void PXPalette_postponeNotifications(PXPalette *self, BOOL postpone)
{
	if([self->undoManager groupingLevel] > 0)
	{
		[[self->undoManager prepareWithInvocationTarget:paletteUndoer] palette:self postponeNotifications:!postpone];
	}
	PXPalette_postponeNotificationsSilently(self, postpone, NO);
}

NSString *PXPalette_name(PXPalette *self)
{
	return self->name;
}

void PXPalette_setName(PXPalette *self, NSString *name)
{
	if([name isEqual:self->name])
	{
		PXPalette_saveChanges(self);
		return;
	}
	id oldName = [self->name autorelease];
	if(self->canSave && [[NSFileManager defaultManager] fileExistsAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:name] stringByAppendingPathExtension:PXPaletteSuffix]])
	{
		NSString *name = self->name;
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[[alert addButtonWithTitle:NSLocalizedString(@"Delete", @"DELETE")] setKeyEquivalent:@""];
		NSButton *button = [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"CANCEL")];
		[button setKeyEquivalent:@"\r"];
		[alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"A palette by that name already exists.  Would you like to overwrite the existing palette?", @"A palette by that name already exists.  Would you like to overwrite the existing palette?"), name]];
		[alert setInformativeText:NSLocalizedString(@"This operation cannot be undone.", @"BACKGROUND_DELETE_INFORMATIVE_TEXT")];
		if([alert runModal] == NSAlertFirstButtonReturn)
		{
			return;
		}
	}
	self->name = [name retain];
	PXPalette_saveChanges(self);
	if(self->canSave)
	{
		[[NSFileManager defaultManager] removeFileAtPath:[[GetPixenPaletteDirectory() stringByAppendingPathComponent:oldName] stringByAppendingPathExtension:PXPaletteSuffix] handler:nil];
	}
}

void PXPalette_addColor(PXPalette *self, NSColor *color)
{
	if (self->locked) {
		return;
	}
	NSColor *colorToAdd = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	if([self->undoManager groupingLevel] > 0)
	{
		[[self->undoManager prepareWithInvocationTarget:paletteUndoer] palette:self removeColorAtIndex:self->colorCount];
	}
	if(!colorToAdd) { return; }
	if (self->size - self->colorCount <= 0) {
		if (self->size < 64) {
			PXPalette_resize(self, 64);
		} else {
			PXPalette_resize(self, self->size * 2);
		}
	}
	self->colors[self->colorCount] = [colorToAdd retain];
	PXPalette_insertColorBucket(self, PXColorBucket_init(PXColorBucket_alloc(), colorToAdd, self->colorCount));
	self->colorCount++;
	PXPalette_saveChanges(self);
	PXPalette_postAddedNotification(self); // so we don't build a dictionary every freakin' time
}

void PXPalette_resize(PXPalette *self, unsigned int newSize)
{
	unsigned int i;
	
	if (self->size == newSize) {
		return;
	}
	
	NSColor **oldColors = self->colors;
	if (newSize > 0) {
		self->colors = (NSColor **)calloc(newSize, sizeof(NSColor *));
	} else {
		self->colors = NULL;
	}
	
	for (i=0; i<self->size; i++) {
		if (i < newSize) {
			self->colors[i] = oldColors[i];
		} else if (i < self->colorCount) {
			if (oldColors == NULL) {
				i = self->colorCount;
			} else {
				PXPalette_removeBucketForColor(self, oldColors[i]);
				[oldColors[i] release];
			}
		}
	}
	
	if (self->size > 0) {
		free(oldColors);
	}
	self->size = newSize;
	if (self->colorCount > self->size) {
		self->colorCount = self->size;
	}
	PXPalette_postChangedNotification(self, [NSDictionary dictionaryWithObjectsAndKeys:PXPaletteResizedNotificationName, PXSubNotificationNameKey, nil]);
}

inline NSColor *PXPalette_colorAtIndex(PXPalette *self, unsigned index)
{
	return self->colors[index];
}

void PXPalette_swapColorsAtIndex(PXPalette* self, unsigned int colorIndex1, unsigned int colorIndex2)
{
	if (colorIndex1 >= self->colorCount || colorIndex2 >= self->colorCount) {
		return;
	}
	if([self->undoManager groupingLevel] > 0)
	{
		[[self->undoManager prepareWithInvocationTarget:paletteUndoer] palette:self swapColorAtIndex:colorIndex2 withColorAtIndex:colorIndex1];
	}
	NSColor *color1 = self->colors[colorIndex1];
	NSColor *color2 = self->colors[colorIndex2];
	PXColorBucket *bucket1 = PXPalette_bucketForColor(self, color1);
	PXColorBucket *bucket2 = PXPalette_bucketForColor(self, color2);
	if (bucket1 != NULL) {
		bucket1->index = colorIndex2;
	}
	if (bucket2 != NULL) {
		bucket2->index = colorIndex1;
	}
	self->colors[colorIndex1] = color2;
	self->colors[colorIndex2] = color1;
	PXPalette_postChangedNotification(self, [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:colorIndex1], PXChangedIndexKey, [NSNumber numberWithUnsignedInt:colorIndex2], @"changedIndex2", PXPaletteSwappedColorsNotificationName, PXSubNotificationNameKey, nil]);
	PXPalette_saveChanges(self);
}

void PXPalette_swapColors(PXPalette* self, NSColor *color1, NSColor *color2)
{
	PXPalette_swapColorsAtIndex(self,
								PXPalette_indexOfColorAddingIfNotPresent(self, color1),
								PXPalette_indexOfColorAddingIfNotPresent(self, color2));
}

//void PXPalette_cycleColors(PXPalette *self)
//{
//#warning ian is to implement undo for this.
//	if (self->locked || self->colorCount < 2) {
//		return;
//	}
//	unsigned int i;
//	NSColor *firstColor = self->colors[1];
//	PXColorBucket *bucket;
//	for (i=1; i<(self->colorCount-1); i++) {
//		self->colors[i] = self->colors[i+1];
//		bucket = PXPalette_bucketForColor(self, self->colors[i+1]);
//		if (bucket != NULL) {
//			bucket->index=i;
//		}
//	}
//	bucket = PXPalette_bucketForColor(self, firstColor);
//	if (bucket != NULL) {
//		bucket->index = self->colorCount-1;
//	}
//	self->colors[self->colorCount-1] = firstColor;
//	PXPalette_postChangedNotification(self, [NSDictionary dictionaryWithObject:PXPaletteCycledColorsNotificationName forKey:PXSubNotificationNameKey]);
//	PXPalette_saveChanges(self);
//}
//
void PXPalette_addBackgroundColor(PXPalette *self)
{
	PXPalette_addColor(self, [NSColor clearColor]);
}

void PXPalette_addColorWithoutDuplicating(PXPalette *self, NSColor *color)
{
	PXPalette_indexOfColorAddingIfNotPresent(self, color);
}

void PXPalette_lock(PXPalette *self)
{
	if([self->undoManager groupingLevel] > 0)
	{
		[[self->undoManager prepareWithInvocationTarget:paletteUndoer] palette:self setLocked:NO];
	}
	self->locked = YES;
	PXPalette_postChangedNotification(self,[NSDictionary dictionaryWithObject:PXPaletteLockedNotificationName forKey:PXSubNotificationNameKey]);
	PXPalette_saveChanges(self);
}

void PXPalette_unlock(PXPalette *self)
{
	if([self->undoManager groupingLevel] > 0)
	{
		[[self->undoManager prepareWithInvocationTarget:paletteUndoer] palette:self setLocked:YES];
	}
	self->locked = NO;
	PXPalette_postChangedNotification(self,[NSDictionary dictionaryWithObject:PXPaletteUnlockedNotificationName forKey:PXSubNotificationNameKey]);
	PXPalette_saveChanges(self);
}

unsigned int PXPalette_indexOfColorClosestTo(PXPalette *self, NSColor *color)
{
	unsigned int i;
	float distance, minDistance=INFINITY;
	unsigned int closestIndex=0;
	for (i=0; i<self->colorCount; i++) {
		distance = [self->colors[i] distanceTo:color];
		if (distance < minDistance) {
			minDistance = distance;
			closestIndex = i;
		}
	}
	return closestIndex;
}

NSColor *PXPalette_colorClosestTo(PXPalette *self, NSColor *color)
{
	unsigned int index = PXPalette_indexOfColorClosestTo(self, color);
	return self->colors[index];
}

NSColor *_PXPalette_correctColor(NSColor *color)
{
	NSColor *colorToCheck = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	if ([colorToCheck alphaComponent] == 0) {
		colorToCheck = [[NSColor clearColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]; // so we don't get lots of clear colors
	}
	return colorToCheck;
}

unsigned int _PXPalette_indexOfCorrectedColor(PXPalette *self, NSColor *colorToCheck)
{
	if (self == NULL) { return -1; }
	PXColorBucket *bucket = PXPalette_bucketForColor(self, colorToCheck);
	if (bucket != NULL) {
		return bucket->index;
	}
	else
		return -1;
}

unsigned int PXPalette_indexOfColor(PXPalette *self, NSColor *color)
{
	if (self == NULL) { return -1; }
	return _PXPalette_indexOfCorrectedColor(self, _PXPalette_correctColor(color));
}

unsigned int PXPalette_indexOfEraseColorAddingIfNotPresent(PXPalette *self)
{
	return PXPalette_indexOfColorAddingIfNotPresent(self, [NSColor clearColor]);
}

unsigned int PXPalette_indexOfColorAddingIfNotPresent(PXPalette *self, NSColor *color)
{
	NSColor *correctedColor = _PXPalette_correctColor(color);
	unsigned int index = _PXPalette_indexOfCorrectedColor(self, correctedColor);
	if (index != -1) {
		return index;
	}
	if (self->locked) {
		return PXPalette_indexOfColorClosestTo(self, correctedColor);
	}
	PXPalette_addColor(self, correctedColor);
	return self->colorCount - 1;
}

NSColor *PXPalette_restrictColor(PXPalette *self, NSColor *color)
{
	if (self->locked) {
		return PXPalette_colorClosestTo(self, color);
	} else {
		return color;
	}
}

double PXPalette_hashEfficiency(PXPalette *self)
{
	int i;
	int bucketsFilled = 0;
	for (i=0; i<65536; i++) {
		if (self->reverseHashTable[i] != NULL) {
			bucketsFilled++;
		}
	}
	return (double)bucketsFilled / (double)(self->colorCount);
}

int PXPalette_colorCount(PXPalette *self)
{
	return self->colorCount;
}

NSArray *PXPalette_colors(PXPalette *self)
{
	return [NSArray arrayWithObjects:self->colors count:self->colorCount];
}

void PXPalette_removeColorAtIndex(PXPalette *self, unsigned int index)
{
	if (self->locked) {
		return;
	}
	NSColor *color = self->colors[index];
	if([self->undoManager groupingLevel] > 0)
	{
		[[self->undoManager prepareWithInvocationTarget:paletteUndoer] palette:self addColor:[color retain]];
		[[self->undoManager prepareWithInvocationTarget:paletteUndoer] palette:self moveColorAtIndex:self->colorCount - 1 toIndex:index adjustIndices:NO];
	}
	PXPalette_removeBucketForColor(self, color);
	[color release];
	int i;
	for(i = index + 1; i < self->colorCount; i++)
	{
		self->colors[i - 1] = self->colors[i];
		PXPalette_bucketForColor(self, self->colors[i])->index--;
	}
	self->colors[self->colorCount] = nil;
	self->colorCount -= 1;
	PXPalette_saveChanges(self);
	PXPalette_postChangedNotification(self, [NSDictionary dictionaryWithObjectsAndKeys:PXPaletteRemovedColorNotificationName, PXSubNotificationNameKey, [NSNumber numberWithUnsignedInt:index], PXChangedIndexKey, nil]);
}

void PXPalette_setColorAtIndex(PXPalette *self, NSColor *color, unsigned int index)
{
	if (index > self->colorCount) {
		return;
	}
	NSColor *oldColor = self->colors[index];
	if([self->undoManager groupingLevel] > 0)
	{
		[[self->undoManager prepareWithInvocationTarget:paletteUndoer] palette:self setColor:oldColor atIndex:index];
	}
	PXPalette_removeBucketForColor(self, oldColor);
	[oldColor release];
	self->colors[index] = [color retain];
	PXPalette_insertColorBucket(self, PXColorBucket_init(PXColorBucket_alloc(), color, index));
	PXPalette_postChangedNotification(self, [NSDictionary dictionaryWithObject:PXPaletteChangedColorNotificationName forKey:PXSubNotificationNameKey]);
	PXPalette_saveChanges(self);
}

// 5 to 3
//    1 2 3 4 5 6
//    1 2 5 3 4 6
//          ^ start at 3+1
//            ^ go to 5

// 3 to 5
//    1 2 3 4 5 6
//    1 2 4 5 3 6
//        ^ start at 3
//          ^ go to 5-1

void PXPalette_moveColorAtIndexToIndex(PXPalette *self, unsigned int index1, unsigned int index2, BOOL adjustIndices)
{
	int i;
	NSColor *color = self->colors[index1];
	if([self->undoManager groupingLevel] > 0)
	{
		[[self->undoManager prepareWithInvocationTarget:paletteUndoer] palette:self moveColorAtIndex:index2 toIndex:index1 adjustIndices:adjustIndices];
	}
	int start;
	int end;
	int shift;
	if (index1 < index2) {
		start = index1;
		end = index2-1;
		shift = 1;
	} else {
		start = index1;
		end = index2+1;
		shift = -1;
	}
	for(i = start; i*shift <= end*shift; i+=shift)
	{
		PXPalette_bucketForColor(self, self->colors[i])->index += shift;
		self->colors[i] = self->colors[i+shift];
	}
	self->colors[index2] = color;
	PXPalette_postChangedNotification(self, [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:index2], PXChangedIndexKey, [NSNumber numberWithUnsignedInt:index1], PXSourceIndexKey, [NSNumber numberWithBool:adjustIndices], PXAdjustIndicesKey, PXPaletteMovedColorNotificationName, PXSubNotificationNameKey, nil]);
	PXPalette_saveChanges(self);
}
