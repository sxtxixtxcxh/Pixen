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

NSString *GetDescriptionForDocumentType(NSString *uti)
{
	if ([uti isEqualToString:@"com.Pixen.pxim"]) {
		return @"Pixen image";
	}
	else if ([uti isEqualToString:@"com.Pixen.pxan"]) {
		return @"Pixen animation";
	}
	else if ([uti isEqualToString:@"com.compuserve.gif"]) {
		return @"GIF image";
	}
	else if ([uti isEqualToString:@"public.jpeg"]) {
		return @"JPEG image";
	}
	else if ([uti isEqualToString:@"public.png"]) {
		return @"PNG image";
	}
	else if ([uti isEqualToString:@"public.tiff"]) {
		return @"TIFF image";
	}
	else if ([uti isEqualToString:@"com.microsoft.bmp"]) {
		return @"BMP image";
	}
	else if ([uti isEqualToString:@"com.microsoft.ico"]) {
		return @"ICO image";
	}
	
	@throw [NSException exceptionWithName:NSGenericException reason:@"Invalid type" userInfo:nil];
	
	return nil;
}
