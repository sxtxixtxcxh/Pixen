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
	CFStringRef cfUTI = (CFStringRef) uti;
	
	if (UTTypeEqual(cfUTI, CFSTR("com.Pixen.pxim"))) {
		return @"Pixen image";
	}
	else if (UTTypeEqual(cfUTI, CFSTR("com.Pixen.pxan"))) {
		return @"Pixen animation";
	}
	else if (UTTypeEqual(cfUTI, CFSTR("com.compuserve.gif"))) {
		return @"GIF image";
	}
	else if (UTTypeEqual(cfUTI, CFSTR("public.jpeg"))) {
		return @"JPEG image";
	}
	else if (UTTypeEqual(cfUTI, CFSTR("public.png"))) {
		return @"PNG image";
	}
	else if (UTTypeEqual(cfUTI, CFSTR("public.tiff"))) {
		return @"TIFF image";
	}
	else if (UTTypeEqual(cfUTI, CFSTR("com.microsoft.bmp"))) {
		return @"BMP image";
	}
	else if (UTTypeEqual(cfUTI, CFSTR("com.microsoft.ico"))) {
		return @"ICO image";
	}
	
	@throw [NSException exceptionWithName:NSGenericException
								   reason:[NSString stringWithFormat:@"Invalid type (%@)", uti]
								 userInfo:nil];
	
	return nil;
}
