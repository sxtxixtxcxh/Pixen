//
//  PXPalette.h
//  Pixen
//
//  Created by Matt Rajca on 8/21/11.
//  Copyright (c) 2011 Matt Rajca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXPalette : NSObject < NSCoding, NSCopying, NSFastEnumeration > {
  @private
	NSMutableArray *_colors;
	NSMapTable *_frequencies;
	NSString *_name;
	
	BOOL canSave, isSystemPalette;
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
