//
//  PXPalette.h
//  Pixen
//
//  Copyright 2011 Pixen Project. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface PXPalette : NSObject < NSCoding, NSCopying, NSFastEnumeration >

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) BOOL canSave;
@property (nonatomic, assign) BOOL isSystemPalette;

+ (NSArray *)systemPalettes;
+ (NSArray *)userPalettes;

- (id)initWithoutBackgroundColor;
- (id)initWithDictionary:(NSDictionary *)dict;

- (void)addBackgroundColor;

- (NSUInteger)colorCount;
- (NSColor *)colorAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfColor:(NSColor *)color;

- (void)addColor:(NSColor *)color;
- (void)addColorWithoutDuplicating:(NSColor *)color;
- (void)insertColor:(NSColor *)color atIndex:(NSUInteger)index;

- (void)removeColorAtIndex:(NSUInteger)index;
- (void)removeLastColor;

- (void)replaceColorAtIndex:(NSUInteger)index withColor:(NSColor *)color;

- (NSColor *)colorClosestToColor:(NSColor *)color;

- (void)incrementCountForColor:(NSColor *)color byAmount:(NSInteger)amount;
- (void)decrementCountForColor:(NSColor *)color byAmount:(NSInteger)amount;

- (void)removeFile;
- (void)save;

- (NSDictionary *)dictForArchiving;

@end
