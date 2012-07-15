//
//  PXAnimationDocument.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXAnimationDocument.h"

#import "PXAnimation.h"
#import "PXAnimationWindowController.h"
#import "PXCel.h"
#import "PXAnimatedGifExporter.h"
#import "PXCanvas_ImportingExporting.h"
#import "OSProgressPopup.h"
#import "PXCanvasWindowController_IBActions.h"
#import "UTType+NSString.h"

@implementation PXAnimationDocument

@synthesize animation = _animation;

- (id)init
{
	self = [super init];
	_animation = [[PXAnimation alloc] init];
	return self;
}

- (void)dealloc
{
	[ (PXAnimationWindowController *) self.windowController setAnimation:nil];
}

//FIXME: consider removing these three once coupling decreases

- (id)canvasController
{
	return [self.windowController canvasController];
}

- (PXCanvas *)canvas
{
	return [[_animation celAtIndex:0] canvas];
}

- (NSArray *)canvases
{
	return [_animation canvases];
}

- (void)delete:(id)sender
{
	[self.windowController delete:sender];
}

- (void)initWindowController
{
	self.windowController = [[PXAnimationWindowController alloc] initWithWindowNibName:@"PXAnimationDocument"];
}

- (void)setWindowControllerData
{
	[ (PXAnimationWindowController *) self.windowController setAnimation:_animation];
}

- (NSString *)lastSavedFileTypeKey
{
	return PXLastSavedAnimationFileType;
}

- (NSString *)defaultFileType
{
	return PixenAnimationFileType;
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)aType error:(NSError **)outError
{
	[[NSUserDefaults standardUserDefaults] setObject:aType forKey:[self lastSavedFileTypeKey]];
	
	if (UTTypeEqualNSString(aType, PixenAnimationFileType) ||
		UTTypeEqualNSString(aType, PixenAnimationFileTypeOld))
	{
		NSMutableDictionary *files = [NSMutableDictionary dictionaryWithCapacity:[_animation countOfCels]];
		NSMutableArray *celData = [NSMutableArray arrayWithCapacity:[_animation countOfCels]];
		int i;
		for (i = 0; i < [_animation countOfCels]; i++)
		{
			PXCel *current = [_animation celAtIndex:i];
			NSFileWrapper *file = [[NSFileWrapper alloc] initRegularFileWithContents:[NSKeyedArchiver archivedDataWithRootObject:[current canvas]]];
			[files setObject:file forKey:[NSString stringWithFormat:@"%d.%@", i, PXISuffix]];
			[celData addObject:[current info]];
		}
		NSString *error = nil;
		NSData *xmlData = [NSPropertyListSerialization dataFromPropertyList:celData format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
		if(!xmlData)
		{
			NSLog(@"%@", error);
			return nil;
		}
		[files setObject:[[NSFileWrapper alloc] initRegularFileWithContents:xmlData] forKey:@"CelData.plist"];
		return [[NSFileWrapper alloc] initDirectoryWithFileWrappers:files];
	}
	else if (UTTypeEqual(kUTTypeGIF, (__bridge CFStringRef)aType))
	{
		NSError *err = nil;
		NSData *data = [self dataOfType:(NSString *)kUTTypeGIF error:&err];
		if(err) 
		{
			[self presentError:err];
			return nil;
		}
		else
		{
			return [[NSFileWrapper alloc] initRegularFileWithContents:data];
		}
	}
	return nil;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	[[NSUserDefaults standardUserDefaults] setObject:typeName forKey:[self lastSavedFileTypeKey]];
	
	if (UTTypeEqual(kUTTypeGIF, (__bridge CFStringRef) typeName))
	{
		PXAnimation *exportAnimation = [_animation copy];
		[exportAnimation reduceColorsTo:256 withTransparency:YES matteColor:[NSColor whiteColor]];
		
		NSUInteger numberOfCels = [exportAnimation countOfCels];
		
		OSProgressPopup *popup = [OSProgressPopup sharedProgressPopup];
		[popup setProgress:0];
		[popup setMaxProgress:numberOfCels];
		[popup beginOperationWithStatusText:[NSString stringWithFormat:@"Exporting GIF... (1 of %ld)", numberOfCels]
							   parentWindow:[self.windowController window]];
		
		PXPalette *palette = [exportAnimation newFrequencyPaletteForAllCels];
		
		PXAnimatedGifExporter *exporter = [[PXAnimatedGifExporter alloc] initWithSize:[exportAnimation size] palette:palette];
		
		for (NSUInteger i = 0; i < numberOfCels; i++)
		{
			PXCel *cel = [exportAnimation celAtIndex:i];
			[exporter writeCanvas:[cel canvas] withDuration:[cel duration]];
			
			[popup setStatusText:[NSString stringWithFormat:@"Exporting GIF... (%ld of %ld)", i + 1, numberOfCels]];
			[popup setProgress:i + 1];
		}
		
		NSData *data = [exporter finalizeExport];
		
		[popup endOperation];
		
		return data;
	}
	
	return nil;
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)wrapper ofType:(NSString *)docType error:(NSError **)outError
{
	if (UTTypeEqualNSString(docType, PixenAnimationFileType) ||
		UTTypeEqualNSString(docType, PixenAnimationFileTypeOld))
	{
		[_animation removeCel:[_animation celAtIndex:0]];
		NSDictionary *files = [wrapper fileWrappers];
		NSString *error = nil;
		NSData *plistData = [[files objectForKey:@"CelData.plist"] regularFileContents];
		NSArray *plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&error];
		if(!plist)
		{
			NSLog(@"%@", error);
			return NO;
		}
		if([plist count] == 0) { return NO; }
		PXGrid *firstGrid = nil;
		
		int i;
		for (i = 0; i < [plist count]; i++)
		{
			NSFileWrapper *currentFile = [files objectForKey:[NSString stringWithFormat:@"%d.%@", i, PXISuffix]];
			
			PXCel *cel = [[PXCel alloc] init];
			[cel setCanvas:[NSKeyedUnarchiver unarchiveObjectWithData:[currentFile regularFileContents]]];
			[cel setInfo:[plist objectAtIndex:i]];
			
			if (firstGrid == nil) {
				firstGrid = [[cel canvas] grid];
			} else {
				[[cel canvas] setGrid:firstGrid];
			}
			
			[_animation addCel:cel];
		}
		
		[[self undoManager] removeAllActions];
		[self updateChangeCount:NSChangeCleared];
		
		return (_animation != nil) && ([_animation countOfCels] > 0);
	}
	else if (UTTypeEqual(kUTTypeGIF, (__bridge CFStringRef) docType))
	{
		return [self readFromData:[wrapper regularFileContents] ofType:docType error:outError];
	}
	else
	{
		return NO;
	}
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)docType error:(NSError **)err
{
	if (UTTypeEqual(kUTTypeGIF, (__bridge CFStringRef) docType))
	{
		[_animation removeCel:[_animation celAtIndex:0]];
		NSImage *tempImage = [[NSImage alloc] initWithData:data];
		NSBitmapImageRep *bitmapRep = [[tempImage representations] objectAtIndex:0];
		int frameCount = [[bitmapRep valueForProperty:NSImageFrameCount] intValue];
		int i;
		for (i = 0; i < frameCount; i++)
		{
			[bitmapRep setProperty:NSImageCurrentFrame withValue:[NSNumber numberWithInt:i]];
			PXCel *newCel = [[PXCel alloc] initWithImage:[tempImage copy] animation:_animation];
			// PXCel is retained by the animation in the initializer used above
			// [newCel retain];
			[newCel setDuration:[[bitmapRep valueForProperty:NSImageCurrentFrameDuration] floatValue]];
		}
		[[self undoManager] removeAllActions];
		[self updateChangeCount:NSChangeCleared];
		return (_animation != nil) && ([_animation countOfCels] > 0);
	}
	[[self undoManager] removeAllActions];
	[self updateChangeCount:NSChangeCleared];
	return (_animation != nil) && ([_animation countOfCels] > 0);
}

+ (BOOL)isNativeType:(NSString *)type
{
	if (UTTypeEqual(kUTTypeGIF, (__bridge CFStringRef) type)) { return YES; }
	return [super isNativeType:type];
}

+ (NSArray *)writableTypes
{
	return [[super writableTypes] arrayByAddingObject:(NSString *)kUTTypeGIF];
}

@end
