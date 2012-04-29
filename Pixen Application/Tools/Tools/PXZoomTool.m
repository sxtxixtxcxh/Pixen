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
	return [[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"zoomIn_bw.png"]
									hotSpot:NSMakePoint(5.0f, 5.0f)] autorelease];
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
	[self.switcher setIcon:[NSImage imageNamed:@"zoomIn"] forTool:self];
	return YES;
}

- (BOOL)optionKeyDown
{
	_zoomType = PXZoomOut;
	[self.switcher setIcon:[NSImage imageNamed:@"zoomOut"] forTool:self];
	return YES;
}

@end
