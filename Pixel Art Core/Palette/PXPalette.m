//
//  PXPalette.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXPalette.h"

#import "Constants.h"
#import "NSColor+PXPaletteAdditions.h"
#import "NSMutableArray+ReorderingAdditions.h"
#import "PathUtilities.h"

@implementation PXPalette

@synthesize name = _name, canSave = _canSave, isSystemPalette = _isSystemPalette;

static NSMutableArray *systemPalettes;
static NSMutableArray *userPalettes;

NSArray *CreateGrayList(void);
NSUInteger ColorSize (const void *item);

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
				[palette addColor:PXColorFromNSColor([[current colorWithKey:currentKey] colorUsingColorSpaceName:NSCalibratedRGBColorSpace])];
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
			[palette addColor:PXColorFromNSColor(currentColor)];
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

NSUInteger ColorSize (const void *item)
{
	return sizeof(PXColor);
}

- (id)initWithoutBackgroundColor
{
	self = [super init];
	if (self) {
		_colors = PXColorArrayCreate();
		
		NSPointerFunctions *keyFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStructPersonality | NSPointerFunctionsCopyIn | NSPointerFunctionsMallocMemory];
		NSPointerFunctions *valueFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsIntegerPersonality | NSPointerFunctionsOpaqueMemory];
		
		keyFunctions.sizeFunction = ColorSize;
		
		_frequencies = [[NSMapTable alloc] initWithKeyPointerFunctions:keyFunctions valuePointerFunctions:valueFunctions capacity:0];
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
	self = [self initWithoutBackgroundColor];
	if (self) {
		self.name = [dict objectForKey:@"name"];
		
		for (NSColor *color in [dict objectForKey:@"colors"]) {
			PXColorArrayAppendColor(_colors, PXColorFromNSColor(color));
		}
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	return [self initWithDictionary:[aDecoder decodeObjectForKey:@"palette"]];
}

- (void)dealloc
{
	[_frequencies release];
	[_name release];
	
	PXColorArrayRelease(_colors);
	
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:[self dictForArchiving] forKey:@"palette"];
	[aCoder encodeObject:[NSNumber numberWithInt:3] forKey:@"paletteVersion"];
}

- (BOOL)isEqual:(id)object
{
	if (![object isKindOfClass:[PXPalette class]])
		return NO;
	
	PXPalette *palette = (PXPalette *) object;
	
	return (self == palette) || [palette.name isEqualToString:self.name];
}

- (void)addBackgroundColor
{
	[self addColorWithoutDuplicating:PXGetClearColor()];
}

- (NSUInteger)colorCount
{
	return PXColorArrayCount(_colors);
}

- (PXColor)colorAtIndex:(NSUInteger)index
{
	return PXColorArrayColorAtIndex(_colors, index);
}

- (NSUInteger)indexOfColor:(PXColor)color
{
	return PXColorArrayIndexOfColor(_colors, color);
}

- (void)addColor:(PXColor)color
{
	PXColorArrayAppendColor(_colors, color);
}

- (void)addColorWithoutDuplicating:(PXColor)color
{
	if ([self indexOfColor:color] == NSNotFound) {
		[self addColor:color];
	}
}

- (void)insertColor:(PXColor)color atIndex:(NSUInteger)index
{
	PXColorArrayInsertColorAtIndex(_colors, index, color);
}

- (void)removeColorAtIndex:(NSUInteger)index
{
	PXColorArrayRemoveColorAtIndex(_colors, index);
}

- (void)removeLastColor
{
	NSUInteger count = PXColorArrayCount(_colors);
	
	if (count)
		PXColorArrayRemoveColorAtIndex(_colors, count-1);
}

- (void)replaceColorAtIndex:(NSUInteger)index withColor:(PXColor)color
{
	//	CFArrayReplaceValues(_colors, CFRangeMake(index, 1), &color, 1);
}

- (id)copyWithZone:(NSZone *)zone
{
	PXPalette *newPalette = [[PXPalette alloc] initWithoutBackgroundColor];
	newPalette.name = self.name;
	
	PXColorArrayEnumerateWithBlock(_colors, ^(PXColor color) {
		[newPalette addColor:color];
	});
	
	return newPalette;
}

- (PXColor)colorClosestToColor:(PXColor)toColor
{
	__block CGFloat minDistance = INFINITY;
	__block PXColor closestColor = PXGetClearColor();
	
	PXColorArrayEnumerateWithBlock(_colors, ^(PXColor color) {
		
		CGFloat distance = PXColorDistanceToColor(color, toColor);
		
		if (distance < minDistance) {
			minDistance = distance;
			closestColor = color;
		}
		
	});
	
	return closestColor;
}

- (void)incrementCountForColor:(PXColor)color byAmount:(NSInteger)amount
{
	NSUInteger currIndex = [self indexOfColor:color];
	
	if (currIndex == NSNotFound) {
		[self addColor:color];
		currIndex = PXColorArrayCount(_colors)-1;
	}
	
	int value = (int) NSMapGet(_frequencies, &color);
	value += amount;
	
	NSMapInsert(_frequencies, &color, (void *) value);
	
	NSUInteger finalIndex = NSNotFound;
	
	for (NSInteger n = (currIndex-1); n >= 0; n--) {
		PXColor nextColor = [self colorAtIndex:n];
		int nextValue = (int) NSMapGet(_frequencies, &nextColor);
		
		if (nextValue <= value) {
			finalIndex = n;
		}
		else {
			break;
		}
	}
	
	if (finalIndex != NSNotFound) {
		PXColorArrayMoveColor(_colors, currIndex, finalIndex);
	}
}

- (void)decrementCountForColor:(PXColor)color byAmount:(NSInteger)amount
{
	NSUInteger currIndex = [self indexOfColor:color];
	
	if (currIndex == NSNotFound)
		return;
	
	int value = (int) NSMapGet(_frequencies, &color);
	value -= amount;
	
	if (value == 0) {
		NSMapRemove(_frequencies, &color);
		PXColorArrayRemoveColorAtIndex(_colors, [self indexOfColor:color]);
		
		return;
	}
	
	NSMapInsert(_frequencies, &color, (void *) value);
	
	NSUInteger finalIndex = NSNotFound;
	
	for (NSInteger n = (currIndex+1); n < PXColorArrayCount(_colors); n++) {
		PXColor nextColor = [self colorAtIndex:n];
		int nextValue = (int) NSMapGet(_frequencies, &nextColor);
		
		if (value <= nextValue) {
			finalIndex = n;
		}
		else {
			break;
		}
	}
	
	if (finalIndex != NSNotFound) {
		PXColorArrayMoveColor(_colors, currIndex, finalIndex);
	}
}

- (void)removeFile
{
	if (self.canSave)
	{
		NSString *path = [[GetPixenPaletteDirectory() stringByAppendingPathComponent:self.name] stringByAppendingPathExtension:PXPaletteSuffix];
		NSError *error = nil;
		
		if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
		{
			[[NSDocumentController sharedDocumentController] presentError:error];
		}
	}
}

- (void)save
{
	if (self.canSave)
	{
		NSString *path = [[GetPixenPaletteDirectory() stringByAppendingPathComponent:self.name] stringByAppendingPathExtension:PXPaletteSuffix];
		[NSKeyedArchiver archiveRootObject:[self dictForArchiving] toFile:path];
	}
}

- (NSDictionary *)dictForArchiving
{
	NSMutableDictionary *paletteDict = [NSMutableDictionary dictionaryWithCapacity:2];
	[paletteDict setObject:self.name forKey:@"name"];
	
	NSMutableArray *colors = [NSMutableArray array];
	
	PXColorArrayEnumerateWithBlock(_colors, ^(PXColor color) {
		[colors addObject:PXColorToNSColor(color)];
	});
	
	[paletteDict setObject:colors forKey:@"colors"];
	
	return paletteDict;
}

@end
