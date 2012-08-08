//
//  PXPalette.h
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import <AppKit/AppKit.h>

#import "PXColor.h"
#import "PXColorArray.h"

@interface PXPalette : NSObject < NSCoding, NSCopying >
{
  @private
	NSString *_name;
	BOOL _canSave;
	BOOL _isSystemPalette;
	PXColorArrayRef _colors;
}

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) BOOL canSave;
@property (nonatomic, assign) BOOL isSystemPalette;

+ (NSArray *)systemPalettes;
+ (NSArray *)userPalettes;

- (id)initWithoutBackgroundColor;
- (id)initWithDictionary:(NSDictionary *)dict;

- (void)addBackgroundColor;

- (NSUInteger)colorCount;
- (PXColor)colorAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfColor:(PXColor)color;

- (void)enumerateWithBlock:(PXColorArrayEnumerationBlock)block;

- (void)addColor:(PXColor)color;
- (void)addColorWithoutDuplicating:(PXColor)color;
- (void)insertColor:(PXColor)color atIndex:(NSUInteger)index;

- (void)removeColorAtIndex:(NSUInteger)index;
- (void)removeLastColor;

- (void)replaceColorAtIndex:(NSUInteger)index withColor:(PXColor)color;
- (void)moveColorAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)targetIndex;

- (PXColor)colorClosestToColor:(PXColor)color;

- (void)incrementCountForColor:(PXColor)color byAmount:(NSInteger)amount;
- (void)decrementCountForColor:(PXColor)color byAmount:(NSInteger)amount;

- (void)sortWithBlock:(PXColorComparator)block;
- (void)sortByFrequency;

- (void)removeFile;
- (void)save;

- (NSDictionary *)dictForArchiving;

@end
