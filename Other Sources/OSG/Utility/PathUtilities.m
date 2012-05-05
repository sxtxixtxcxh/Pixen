//
//  PathUtilities.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PathUtilities.h"

#import "Constants.h"

NSString *GetApplicationSupportDirectory()
{
	NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
	
	if (![urls count]) {
		[NSException raise:@"Directory Error" format:@"Surprisingly, there was no Application Support directory."];
		return nil;
	}
	
	return [[urls objectAtIndex:0] path];
}

NSString *GetPixenSupportDirectory()
{
	return [GetApplicationSupportDirectory() stringByAppendingPathComponent:@"Pixen"];
}

NSString *GetPixenPaletteDirectory()
{
	return [GetPixenSupportDirectory() stringByAppendingPathComponent:@"Palettes"];
}

NSString *GetPixenBackgroundsDirectory()
{
	return [GetPixenSupportDirectory() stringByAppendingPathComponent:@"Backgrounds"];
}

NSString *GetBackgroundPresetsDirectory()
{
	return [GetPixenBackgroundsDirectory() stringByAppendingPathComponent:@"Presets"];
}

NSString *GetBackgroundImagesDirectory()
{
	return [GetPixenBackgroundsDirectory() stringByAppendingPathComponent:@"Images"];
}

NSString *GetPathForBackgroundNamed(NSString *name)
{
	return [GetBackgroundPresetsDirectory() stringByAppendingPathComponent:[name stringByAppendingPathExtension:PXBackgroundSuffix]];
}

NSString *GetPixenPatternFile()
{
	return [GetPixenSupportDirectory() stringByAppendingPathComponent:@"Patterns.pxpatternarchive"];
}
