//
//  PXZoomTool.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXZoomTool.h"

#import "PXCanvasController.h"
#import "PXToolSwitcher.h"

//TODO: should implement 'drag to create rect and zoom to fit that rect'

@implementation PXZoomTool

- (NSString *)name
{
	return NSLocalizedString(@"ZOOM_NAME", @"Zoom Tool");
}

- (id)init
{
	if ( ! (self = [super init]))
		return nil;
	
	_zoomType = PXZoomIn;
	
	return self;
}

- (NSCursor *)cursor
{
	NSString *name = _zoomType == PXZoomIn ? @"zoomIn_bw.png" : @"zoomOut_bw.png";
	
	return [[NSCursor alloc] initWithImage:[NSImage imageNamed:name]
									hotSpot:NSMakePoint(5.0f, 5.0f)];
}

- (void)mouseDownAt:(NSPoint)aPoint fromCanvasController:(PXCanvasController *)controller
{
	if (_zoomType == PXZoomIn)
	{
		[controller zoomInOnCanvasPoint:aPoint];
	}
	else if (_zoomType == PXZoomOut)
	{
		[controller zoomOutOnCanvasPoint:aPoint];
	}
}

- (BOOL)optionKeyUp
{
	_zoomType = PXZoomIn;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXToolCursorChangedNotificationName
														object:self];
	
	[self.switcher setIcon:[NSImage imageNamed:@"zoomIn"] forTool:self];
	return YES;
}

- (BOOL)optionKeyDown
{
	_zoomType = PXZoomOut;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PXToolCursorChangedNotificationName
														object:self];
	
	[self.switcher setIcon:[NSImage imageNamed:@"zoomOut"] forTool:self];
	return YES;
}

@end
