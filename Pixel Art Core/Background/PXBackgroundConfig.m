//
//  PXBackgroundConfig.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXBackgroundConfig.h"

#import "PXBackgrounds.h"

@implementation PXBackgroundConfig

@synthesize mainBackground = _mainBackground, alternateBackground = _alternateBackground;
@synthesize mainPreviewBackground = _mainPreviewBackground, alternatePreviewBackground = _alternatePreviewBackground;

- (id)init
{
	self = [super init];
	if (self) {
		[self setDefaultBackgrounds];
		[self setDefaultPreviewBackgrounds];
	}
	return self;
}

- (id)initWithMainBG:(PXBackground *)mbg altBG:(PXBackground *)abg prevMainBG:(PXBackground *)pmbg altBG:(PXBackground *)pabg
{
	self = [self init];
	if (self) {
		if (mbg)
		{
			[self setMainBackground:mbg];
			[self setAlternateBackground:abg];
		}
		
		if (pmbg)
		{
			[self setMainPreviewBackground:pmbg];
			[self setAlternatePreviewBackground:pabg];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.mainBackground forKey:@"mainBackground"];
	[coder encodeObject:self.alternateBackground forKey:@"alternateBackground"];
	[coder encodeObject:self.mainPreviewBackground forKey:@"mainPreviewBackground"];
	[coder encodeObject:self.alternatePreviewBackground forKey:@"alternatePreviewBackground"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	return [self initWithMainBG:[coder decodeObjectForKey:@"mainBackground"]
						  altBG:[coder decodeObjectForKey:@"alternateBackground"]
					 prevMainBG:[coder decodeObjectForKey:@"mainPreviewBackground"]
						  altBG:[coder decodeObjectForKey:@"alternatePreviewBackground"]];
}

- (void)setDefaultBackgrounds
{
	NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:PXCanvasDefaultMainBackgroundKey];
	
	if (data)
	{
		[self setMainBackground:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
	}
	else
	{
		PXSlashyBackground *background = [[PXSlashyBackground alloc] init];
		[self setMainBackground:background];
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:background]
												  forKey:PXCanvasDefaultMainBackgroundKey];
	}
	
	data = [[NSUserDefaults standardUserDefaults] dataForKey:PXCanvasDefaultAlternateBackgroundKey];
	
	if (data)
	{
		[self setAlternateBackground:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
	}
}

- (void)setDefaultPreviewBackgrounds
{
	NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:PXPreviewDefaultMainBackgroundKey];
	
	if (data)
	{
		[self setMainPreviewBackground:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
	}
	else
	{
		PXMonotoneBackground *background = [[PXMonotoneBackground alloc] init];
		[self setMainPreviewBackground:background];
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:background]
												  forKey:PXPreviewDefaultMainBackgroundKey];
	}
	
	data = [[NSUserDefaults standardUserDefaults] dataForKey:PXPreviewDefaultAlternateBackgroundKey];
	
	if (data)
	{
		[self setAlternatePreviewBackground:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
	}
}

@end
