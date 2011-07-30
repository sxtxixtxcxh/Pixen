//
//  PXPreferencesController.m
//  Pixen
//

#import "PXPreferencesController.h"

#import "PXGeneralPreferencesController.h"
#import "PXHotkeysPreferencesController.h"

@implementation PXPreferencesController

+ (id)sharedPreferencesController
{
	static PXPreferencesController *sharedPreferences = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedPreferences = [[self alloc] init];
	});
	
	return sharedPreferences;
}

- (id)init
{
	self = [super initWithWindowNibName:@"PXPreferences"];
	_selectedTab = -1;
	return self;
}

- (void)dealloc
{
	[_generalVC release];
	[_hotkeysVC release];
	[super dealloc];
}

- (void)awakeFromNib
{
	[[[self window] toolbar] setSelectedItemIdentifier:@"General"];
	[self selectGeneralTab:nil];
}

- (void)selectViewController:(NSViewController *)vc
{
	for (NSView *subview in [[[self window] contentView] subviews]) {
		[subview removeFromSuperview];
	}
	
	NSView *childView = vc.view;
	
	NSRect frame = [self window].frame;
	CGFloat deltaY = [ (NSView *) [[self window] contentView] bounds].size.height - childView.bounds.size.height;
	
	frame.origin.y += deltaY;
	frame.size.height -= deltaY;
	
	if (_selectedTab != -1) {
		[[[self window] animator] setFrame:frame display:YES];
	}
	else {
		[[self window] setFrame:frame display:YES];
	}
	
	[[[self window] contentView] addSubview:childView];
}

- (IBAction)selectGeneralTab:(id)sender
{
	if (!_generalVC) {
		_generalVC = [[PXGeneralPreferencesController alloc] init];
	}
	
	[self selectViewController:_generalVC];
	_selectedTab = PXPreferencesTabGeneral;
}

- (IBAction)selectHotkeysTab:(id)sender
{
	if (!_hotkeysVC) {
		_hotkeysVC = [[PXHotkeysPreferencesController alloc] init];
	}
	
	[self selectViewController:_hotkeysVC];
	_selectedTab = PXPreferencesTabHotkeys;
}

@end
