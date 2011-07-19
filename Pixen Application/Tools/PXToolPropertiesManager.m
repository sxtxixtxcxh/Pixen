//
//  PXToolPropertiesManager.m
//  Pixen
//
//  Copyright Matt Rajca 2011. All rights reserved.
//

#import "PXToolPropertiesManager.h"

#import "PXTool.h"
#import "PXToolPaletteController.h"
#import "PXToolPropertiesController.h"
#import "PXToolSwitcher.h"
#import "PXNotifications.h"

@interface PXToolPropertiesManager (Private)

- (void)_toolDidChange:(NSNotification *)notification;

@end


@implementation PXToolPropertiesManager (Private)

- (void)_toolDidChange:(NSNotification *)aNotification
{
	NSMutableString *title = [NSMutableString string];
	[title appendString:[[[aNotification userInfo] objectForKey:PXNewToolKey] name]];
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
	
	PXTool *tool = [[aNotification userInfo] objectForKey:PXNewToolKey];
	PXToolPropertiesController *controller = [tool propertiesController];
	
	if (!controller) {
		controller = [tool createPropertiesController];
	}
	
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
	
	if (self.side == PXToolPropertiesSideLeft) {
		[self.window setFrameAutosaveName:@"PXLeftToolPropertiesFrame"];
	}
	else {
		[self.window setFrameAutosaveName:@"PXRightToolPropertiesFrame"];
	}
	
	[self setPropertiesController:[[PXToolPropertiesController new] autorelease]];
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
		
		PXToolSwitcher *switcher = aSide == PXToolPropertiesSideLeft ?
		[[PXToolPaletteController sharedToolPaletteController] leftSwitcher] :
		[[PXToolPaletteController sharedToolPaletteController] rightSwitcher];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_toolDidChange:)
													 name:PXToolDidChangeNotificationName
												   object:switcher];
		
		[switcher requestToolChangeNotification];
	}
	return self;
}

+ (id)leftToolPropertiesManager
{
	static PXToolPropertiesManager *leftInstance = nil;
	static dispatch_once_t leftOnceToken;
	
	dispatch_once(&leftOnceToken, ^{
		leftInstance = [[PXToolPropertiesManager alloc] initWithSide:PXToolPropertiesSideLeft];
	});
	
	return leftInstance;
}

+ (id)rightToolPropertiesManager
{
	static PXToolPropertiesManager *rightInstance = nil;
	static dispatch_once_t rightOnceToken;
	
	dispatch_once(&rightOnceToken, ^{
		rightInstance = [[PXToolPropertiesManager alloc] initWithSide:PXToolPropertiesSideRight];
	});
	
	return rightInstance;
}

- (void)setPropertiesController:(PXToolPropertiesController *)aController {
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
			
			[[window animator] setFrame:frame display:YES];
			
			[[window contentView] addSubview:childView];
			[[window contentView] addSubview:aController.view];
		}
	}
}

@end
