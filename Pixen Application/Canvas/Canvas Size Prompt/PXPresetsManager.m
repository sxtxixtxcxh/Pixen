//
//  PXPresetsManager.m
//  Pixen
//
//  Created by Matt Rajca on 7/15/11.
//  Copyright 2011 Matt Rajca. All rights reserved.
//

#import "PXPresetsManager.h"

#import "PXPreset.h"

@implementation PXPresetsManager

+ (id)sharedPresetsManager
{
	static PXPresetsManager *sharedPresetsManager;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedPresetsManager = [[PXPresetsManager alloc] init];
	});
	
	return sharedPresetsManager;
}

- (NSString *)presetsPath
{
	NSString *appSupport = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
	NSString *pixen = [appSupport stringByAppendingPathComponent:@"Pixen"];
	
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if (![manager fileExistsAtPath:pixen isDirectory:NULL]) {
		[manager createDirectoryAtPath:pixen withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	return [pixen stringByAppendingPathComponent:@"Presets.plist"];
}

- (id)init
{
	self = [super init];
	if (self) {
		_presets = [[NSMutableArray alloc] init];
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:[self presetsPath]]) {
			NSArray *presets = [NSKeyedUnarchiver unarchiveObjectWithFile:[self presetsPath]];
			
			if ([presets isKindOfClass:[NSArray class]]) {
				[_presets addObjectsFromArray:presets];
			}
		}
	}
	return self;
}

- (void)dealloc
{
    [_presets release];
	[super dealloc];
}

- (NSArray *)presets
{
	return _presets;
}

- (NSArray *)presetNames
{
	return [_presets valueForKey:@"name"];
}

- (PXPreset *)presetWithName:(NSString *)name
{
	for (PXPreset *preset in _presets) {
		if ([preset.name isEqualToString:name]) {
			return preset;
		}
	}
	
	return nil;
}

- (void)persistPresets
{
	[NSKeyedArchiver archiveRootObject:_presets toFile:[self presetsPath]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXPresetsChangedNotificationName
														object:self];
}

- (void)savePresetWithName:(NSString *)name size:(NSSize)size color:(NSColor *)color
{
	PXPreset *existingPreset = [self presetWithName:name];
	
	if (existingPreset) {
		existingPreset.size = size;
		existingPreset.color = color;
	}
	else {
		PXPreset *preset = [[PXPreset alloc] init];
		preset.name = name;
		preset.size = size;
		preset.color = color;
		
		[_presets addObject:preset];
		[preset release];
	}
	
	[self persistPresets];
}

- (void)removePresetWithName:(NSString *)name
{
	PXPreset *preset = [self presetWithName:name];
	
	if (!preset)
		return;
	
	[_presets removeObject:preset];
	
	[self persistPresets];
}

@end
