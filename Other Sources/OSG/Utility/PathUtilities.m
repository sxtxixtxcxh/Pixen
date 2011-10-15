//
//  PathUtilities.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PathUtilities.h"

#import "Constants.h"

NSString *GetApplicationSupportDirectory()
{
	//Check the Library user path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDir;
	NSString *path;
	
	if ([paths count] == 0)
	{
		[NSException raise:@"Directory Error" format:@"Surprisingly, there was no Library."];
		return @"";
	}
	
	path = [paths objectAtIndex:0];
	
	//Application Support
	path = [path stringByAppendingPathComponent:@"Application Support"];
	
	if ((![fileManager fileExistsAtPath:path isDirectory:&isDir]) || !isDir)
	{
		[NSException raise:@"Directory Error" format:@"Surprisingly, there was no Application Support directory."];
		return @"";
	}
	
	return path;
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
