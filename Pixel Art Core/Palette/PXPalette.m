//
//  PXPalette.m
//  Pixen
//
//  Created by Matt Rajca on 8/21/11.
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import "PXPalette.h"

#import "NSMutableArray+ReorderingAdditions.h"
#import "PathUtilities.h"

@implementation PXPalette

@synthesize name = _name, canSave, isSystemPalette;

static NSMutableArray *systemPalettes;
static NSMutableArray *userPalettes;

NSArray *CreateGrayList(void);

#define LOG_COLOR	[NSColor colorWithCalibratedRed:rgb green:rgb blue:rgb alpha:log2(64 - i) * 0.1667]

NSArray *CreateGrayList()
{
	float rgb = 0.0f;
	
	NSMutableArray *grays = [NSMutableArray arrayWithCapacity:256];
	
	int i = 0;
	
	for (i = 0; i < 64; i++) {
		rgb = (float)i / 64.0f;
		NSColor *color = [NSColor colorWithCalibratedRed:rgb green:rgb blue:rgb alpha:1.0f];
		[grays addObject:color];
	}
	
	rgb = 0.0f;
	
	for (i = 0; i < 64; i++) {
		[grays addObject:LOG_COLOR];
	}
	
	rgb = 0.5f;
	
	for (i = 0; i < 64; i++) {
		[grays addObject:LOG_COLOR];
	}
	
	rgb = 1.0f;
	
	for (i = 0; i < 64; i++) {
		[grays addObject:LOG_COLOR];
	}
	
	return grays;
}

+ (NSArray *)systemPalettes
{
	NSArray *lists = [NSColorList availableColorLists];
	NSUInteger newCount = [lists count]+1;
	
	if (systemPalettes == nil)
		systemPalettes = [[NSMutableArray alloc] init];
	
	if (newCount != [systemPalettes count])
	{
		[systemPalettes removeAllObjects];
		
		for (NSColorList *current in lists)
		{
			PXPalette *palette = [[PXPalette alloc] initWithoutBackgroundColor];
			palette.name = [current name];
			
			for (NSString *currentKey in [current allKeys])
			{
				[palette addColor:[current colorWithKey:currentKey]];
			}
			
			palette.isSystemPalette = YES;
			palette.canSave = NO;

			[systemPalettes addObject:palette];
			[palette release];
		}
		
		NSMutableArray *grays = [NSMutableArray arrayWithArray:CreateGrayList()];
		
		PXPalette *palette = [[PXPalette alloc] initWithoutBackgroundColor];
		palette.name = NSLocalizedString(@"GRAYSCALE", @"Grayscale");
		palette.isSystemPalette = YES;
		palette.canSave = NO;
		
		for (NSColor *currentColor in grays)
		{
			[palette addColor:currentColor];
		}
		
		[systemPalettes addObject:palette];
		[palette release];
	}
	
	return systemPalettes;
}

+ (NSArray *)userPalettes
{
	NSMutableArray *paths = [NSMutableArray array];
	NSEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:GetPixenPaletteDirectory()];
	
	for (NSString *currentPath in enumerator)
	{
		if ([[currentPath pathExtension] isEqual:PXPaletteSuffix])
		{
			[paths addObject:[currentPath stringByDeletingPathExtension]];
		}
	}
	
	[paths sortUsingSelector:@selector(compareNumeric:)];
	
	NSUInteger newCount = [paths count];
	
	if (userPalettes == nil)
		userPalettes = [[NSMutableArray alloc] init];
	
	if (newCount != [userPalettes count])
	{
		[userPalettes removeAllObjects];
		
		for (NSUInteger i = 0; i < [paths count]; i++)
		{
			NSString *path = [[GetPixenPaletteDirectory() stringByAppendingPathComponent:[paths objectAtIndex:i]] stringByAppendingPathExtension:PXPaletteSuffix];
			NSDictionary *object = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
			
			PXPalette *palette = [[PXPalette alloc] initWithDictionary:object];
			palette.isSystemPalette = NO;
			palette.canSave = YES;
			
			[userPalettes addObject:palette];
			[palette release];
		}
	}
	
	return userPalettes;
}

- (id)init
{
	self = [self initWithoutBackgroundColor];
	if (self) {
		[self addBackgroundColor];
	}
	return self;
}

- (id)initWithoutBackgroundColor
{
	self = [super init];
	if (self) {
		_colors = [[NSMutableArray alloc] init];
		_frequencies = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsObjectPersonality
												 valueOptions:NSPointerFunctionsIntegerPersonality | NSPointerFunctionsOpaqueMemory
													 capacity:0];
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
	self = [self initWithoutBackgroundColor];
	if (self) {
		self.name = [dict objectForKey:@"name"];
		[_colors addObjectsFromArray:[dict objectForKey:@"colors"]];
	}
	return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained *)stackbuf count:(NSUInteger)len
{
	return [_colors countByEnumeratingWithState:state objects:stackbuf count:len];
}

- (BOOL)isEqual:(id)object
{
	if (![object isKindOfClass:[PXPalette class]])
		return NO;
	
	PXPalette *palette = (PXPalette *) object;
	
	return (self == palette) || [palette.name isEqualToString:_name];
}

- (void)addBackgroundColor
{
	[self addColorWithoutDuplicating:[[NSColor clearColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
}

- (NSUInteger)colorCount
{
	return [_colors count];
}

- (NSColor *)colorAtIndex:(NSUInteger)index
{
	return [_colors objectAtIndex:index];
}

- (NSUInteger)indexOfColor:(NSColor *)color
{
	return [_colors indexOfObject:color];
}

- (void)addColor:(NSColor *)color
{
	[_colors addObject:color];
}

- (void)addColorWithoutDuplicating:(NSColor *)color
{
	if ([_colors indexOfObject:color] == NSNotFound) {
		[_colors addObject:color];
	}
}

- (void)insertColor:(NSColor *)color atIndex:(NSUInteger)index
{
	[_colors insertObject:color atIndex:index];
}

- (void)removeColorAtIndex:(NSUInteger)index
{
	[_colors removeObjectAtIndex:index];
}

- (void)removeLastColor
{
	[_colors removeLastObject];
}

- (void)replaceColorAtIndex:(NSUInteger)index withColor:(NSColor *)color
{
	[_colors replaceObjectAtIndex:index withObject:color];
}

- (id)copyWithZone:(NSZone *)zone
{
	PXPalette *newPalette = [[PXPalette alloc] initWithoutBackgroundColor];
	newPalette.name = _name;
	
	for (NSColor *color in _colors) {
		[newPalette addColor:color];
	}
	
	return newPalette;
}

- (void)incrementCountForColor:(NSColor *)color byAmount:(NSInteger)amount
{
	NSUInteger currIndex = [_colors indexOfObject:color];
	
	if (currIndex == NSNotFound) {
		[_colors addObject:color];
		currIndex = [_colors count]-1;
	}
	
	int value = (int) NSMapGet(_frequencies, (__bridge const void *) color);
	value += amount;
	
	NSMapInsert(_frequencies, (__bridge const void *) color, (void *) value);
	
	NSUInteger finalIndex = NSNotFound;
	
	for (NSInteger n = (currIndex-1); n >= 0; n--) {
		NSColor *nextColor = [_colors objectAtIndex:n];
		int nextValue = (int) NSMapGet(_frequencies, (__bridge const void *) nextColor);
		
		if (nextValue <= value) {
			finalIndex = n;
		}
		else {
			break;
		}
	}
	
	if (finalIndex != NSNotFound) {
		[_colors moveObjectAtIndex:currIndex toIndex:finalIndex];
	}
}

- (void)decrementCountForColor:(NSColor *)color byAmount:(NSInteger)amount
{
	NSUInteger currIndex = [_colors indexOfObject:color];
	
	if (currIndex == NSNotFound)
		return;
	
	int value = (int) NSMapGet(_frequencies, (__bridge const void *) color);
	value -= amount;
	
	if (value == 0) {
		NSMapRemove(_frequencies, (__bridge const void *) color);
		[_colors removeObject:color];
		
		return;
	}
	
	NSMapInsert(_frequencies, (__bridge const void *) color, (void *) value);
	
	NSUInteger finalIndex = NSNotFound;
	
	for (NSInteger n = currIndex+1; n < [_colors count]; n++) {
		NSColor *nextColor = [_colors objectAtIndex:n];
		int nextValue = (int) NSMapGet(_frequencies, (__bridge const void *) nextColor);
		
		if (value <= nextValue) {
			finalIndex = n;
		}
		else {
			break;
		}
	}
	
	if (finalIndex != NSNotFound) {
		[_colors moveObjectAtIndex:currIndex toIndex:finalIndex];
	}
}

- (void)removeFile
{
	if (canSave)
	{
		NSString *path = [[GetPixenPaletteDirectory() stringByAppendingPathComponent:_name] stringByAppendingPathExtension:PXPaletteSuffix];
		NSError *error = nil;
		
		if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
		{
			[[NSDocumentController sharedDocumentController] presentError:error];
		}
	}
}

- (void)save
{
	if (canSave)
	{
		NSString *path = [[GetPixenPaletteDirectory() stringByAppendingPathComponent:_name] stringByAppendingPathExtension:PXPaletteSuffix];
		[NSKeyedArchiver archiveRootObject:[self dictForArchiving] toFile:path];
	}
}

- (NSDictionary *)dictForArchiving
{
	NSMutableDictionary *paletteDict = [NSMutableDictionary dictionaryWithCapacity:2];
	[paletteDict setObject:_name forKey:@"name"];
	[paletteDict setObject:_colors forKey:@"colors"];
	
	return paletteDict;
}

@end
