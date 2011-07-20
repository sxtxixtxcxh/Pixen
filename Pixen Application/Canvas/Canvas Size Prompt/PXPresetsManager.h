//
//  PXPresetsManager.h
//  Pixen
//
//  Created by Matt Rajca on 7/15/11.
//  Copyright 2011 Matt Rajca. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PXPreset;

@interface PXPresetsManager : NSObject
{
  @private
	NSMutableArray *_presets;
}

+ (id)sharedPresetsManager;

- (NSArray *)presets;
- (NSArray *)presetNames;

- (PXPreset *)presetWithName:(NSString *)name;

- (void)persistPresets;

- (void)savePresetWithName:(NSString *)name size:(NSSize)size color:(NSColor *)color;
- (void)removePresetWithName:(NSString *)name;

@end
