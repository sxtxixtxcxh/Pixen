//
//  PXToolPropertiesManager.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXToolPropertiesManager.h"

#import "PXNotifications.h"
#import "PXTool.h"
#import "PXToolPaletteController.h"
#import "PXToolPropertiesController.h"
#import "PXToolSwitcher.h"

@interface PXToolPropertiesManager (Private)

- (void)toolDidChange:(NSNotification *)notification;

@end


@implementation PXToolPropertiesManager (Private)

- (void)toolDidChange:(NSNotification *)notification
{
	PXTool *tool = [[notification userInfo] objectForKey:PXNewToolKey];
	
	NSMutableString *title = [NSMutableString string];
	[title appendString:[tool name]];
	[title appendString:@" ("];
	
	if (self.side == PXToolPropertiesSideLeft) {
		[title appendString:NSLocalizedString(@"LEFT", @"Left")];
	}
	else {
		[title appendString:NSLocalizedString(@"RIGHT", @"Right")];
	}
	
	[title appendString:@") "];
	[title appendString:NSLocalizedString(@"PROPERTIES", @"Properties")];
	
	[self.window setTitle:title];
	
	PXToolPropertiesController *controller = [tool propertiesController];
	
	if (!controller) {
		self.propertiesController = [[PXToolPropertiesController new] autorelease];
	}
	else {
		self.propertiesController = controller;
	}
}

@end


@implementation PXToolPropertiesManager

@synthesize side = _side, propertiesController = _propertiesController;

- (void)awakeFromNib
{
	[ (NSPanel *) self.window setBecomesKeyOnlyIfNeeded:YES];
}

- (void)dealloc
{
	[_propertiesController release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (id)initWithSide:(PXToolPropertiesSide)aSide
{
	self = [super initWithWindowNibName:@"PXToolProperties"];
	if (self) {
		_side = aSide;
	}
	return self;
}

+ (PXToolPropertiesManager *)leftToolPropertiesManager
{
	static PXToolPropertiesManager *leftInstance = nil;
	static dispatch_once_t leftOnceToken;
	
	dispatch_once(&leftOnceToken, ^{
		leftInstance = [[PXToolPropertiesManager alloc] initWithSide:PXToolPropertiesSideLeft];
	});
	
	return leftInstance;
}

+ (PXToolPropertiesManager *)rightToolPropertiesManager
{
	static PXToolPropertiesManager *rightInstance = nil;
	static dispatch_once_t rightOnceToken;
	
	dispatch_once(&rightOnceToken, ^{
		rightInstance = [[PXToolPropertiesManager alloc] initWithSide:PXToolPropertiesSideRight];
	});
	
	return rightInstance;
}

- (void)setPropertiesController:(PXToolPropertiesController *)aController
{
	if (_propertiesController != aController)
	{
		[_propertiesController release];
		_propertiesController = [aController retain];
		
		for (NSView *subview in [[self.window contentView] subviews])
		{
			[subview removeFromSuperview];
		}
		
		if (aController)
		{
			NSWindow *window = self.window;
			NSView *childView = aController.view;
			NSRect frame = window.frame;
			
			CGFloat deltaY = [ (NSView *) [window contentView] bounds].size.height - childView.bounds.size.height;
			frame.origin.y += deltaY;
			frame.size.height -= deltaY;
			
			if ([window isVisible])
				[[window animator] setFrame:frame display:YES];
			else
				[window setFrame:frame display:YES];
			
			[[window contentView] addSubview:childView];
		}
	}
}

- (void)showWindow:(id)sender
{
	BOOL isLeft = (_side == PXToolPropertiesSideLeft);
	NSString *key = isLeft ? PXLeftToolPropertiesFrameKey : PXRightToolPropertiesFrameKey;
	NSRect frame = NSRectFromString([[NSUserDefaults standardUserDefaults] stringForKey:key]);
	
	if (!NSEqualRects(frame, NSZeroRect)) {
		NSWindow *window = [self window];
		[window setFrame:frame display:YES];
	}
	
	PXToolPaletteController *controller = [PXToolPaletteController sharedToolPaletteController];
	PXToolSwitcher *switcher = isLeft ? [controller leftSwitcher] : [controller rightSwitcher];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(toolDidChange:)
												 name:PXToolDidChangeNotificationName
											   object:switcher];
	
	[switcher requestToolChangeNotification];
	
	[super showWindow:sender];
}

@end
