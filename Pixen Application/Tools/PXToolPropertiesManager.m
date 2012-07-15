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
		self.propertiesController = [PXToolPropertiesController new];
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithSide:(PXToolPropertiesSide)side
{
	self = [super initWithWindowNibName:@"PXToolProperties"];
	if (self) {
		_side = side;
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

- (void)setPropertiesController:(PXToolPropertiesController *)controller
{
	if (_propertiesController != controller)
	{
		_propertiesController = controller;
		
		for (NSView *subview in [[self.window contentView] subviews])
		{
			[subview removeFromSuperview];
		}
		
		if (controller)
		{
			NSWindow *window = self.window;
			NSRect frame = window.frame;
			NSView *childView = controller.view;
			
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

- (void)windowDidLoad
{
	BOOL isLeft = (_side == PXToolPropertiesSideLeft);
	NSString *key = isLeft ? PXLeftToolPropertiesFrameKey : PXRightToolPropertiesFrameKey;
	NSRect frame = NSRectFromString([[NSUserDefaults standardUserDefaults] stringForKey:key]);
	
	if (!NSEqualRects(frame, NSZeroRect)) {
		[self.window setFrame:frame display:YES];
	}
	
	PXToolPaletteController *controller = [PXToolPaletteController sharedToolPaletteController];
	PXToolSwitcher *switcher = isLeft ? [controller leftSwitcher] : [controller rightSwitcher];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(toolDidChange:)
												 name:PXToolDidChangeNotificationName
											   object:switcher];
	
	[switcher requestToolChangeNotification];
}

@end
