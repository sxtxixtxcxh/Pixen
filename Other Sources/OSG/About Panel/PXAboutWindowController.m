//
//  PXAboutWindowController.m
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXAboutWindowController.h"

#import "PXAboutController.h"
#import "PXAboutPanel.h"

#import <QuartzCore/QuartzCore.h>

@interface PXAboutWindowController ()

- (PXAboutController *)viewController;
- (NSDictionary *)animationDictionary;

- (void)watchForNotificationsWhichShouldHidePanel;

- (void)hidePanel;

@end


@implementation PXAboutWindowController

+ (id)sharedController
{
	static PXAboutWindowController *singleInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		singleInstance = [[self alloc] init];
	});
	
	return singleInstance;
}

- (PXAboutController *)viewController
{
	if (!_viewController) {
		_viewController = [[PXAboutController alloc] init];
	}
	
	return _viewController;
}

- (NSWindow *)window
{
	if (!_aboutPanel) {
		NSView *contentView = [self viewController].view;
		
		_aboutPanel = [[PXAboutPanel alloc] initWithContentRect:[contentView frame]
													  styleMask:NSBorderlessWindowMask
														backing:NSBackingStoreBuffered
														  defer:NO];
		
		[_aboutPanel setBackgroundColor:[NSColor whiteColor]];
		[_aboutPanel setHasShadow:YES];
		[_aboutPanel setAnimations:[self animationDictionary]];
		[_aboutPanel setNextResponder:self];
		[_aboutPanel setBecomesKeyOnlyIfNeeded:NO];
		[_aboutPanel setLevel:NSModalPanelWindowLevel];
		[_aboutPanel setContentView:contentView];
		[_aboutPanel setDelegate:self];
		
		[self watchForNotificationsWhichShouldHidePanel];
	}
	
	return (NSWindow *) _aboutPanel;
}

- (NSDictionary *)animationDictionary
{
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"alphaValue"];
	animation.delegate = self;
	
	return [NSDictionary dictionaryWithObject:animation forKey:@"alphaValue"];
}

- (void)showWindow:(id)sender
{
	PXAboutPanel *panel = (PXAboutPanel *) [self window];
	
	[panel setAlphaValue:0.0f];
	[panel center];
	[panel makeKeyAndOrderFront:nil];
	
	[[panel animator] setAlphaValue:1.0f];
}

// Watch for notifications that the application is no longer active, or that
// another window has replaced the About panel as the main window, and hide
// on either of these notifications.
- (void)watchForNotificationsWhichShouldHidePanel
{
	// This works better than just making the panel hide when the app
	// deactivates (setHidesOnDeactivate:YES), because if we use that
	// then the panel will return when the app reactivates.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(hidePanel)
			   name:NSApplicationDidResignActiveNotification
			 object:nil];
	
	// If the panel is no longer main, hide it.
	// (We could also use the delegate notification for this.)
	[nc addObserver:self
		   selector:@selector(hidePanel)
			   name:NSWindowDidResignMainNotification
			 object:_aboutPanel];
	
	[nc addObserver:self
		   selector:@selector(hidePanel)
			   name:NSWindowDidResignKeyNotification
			 object:_aboutPanel];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
	if ([_aboutPanel alphaValue] == 0)
		[_aboutPanel orderOut:nil];
}

- (void)hidePanel
{
	[[_aboutPanel animator] setAlphaValue:0.0f];
}

- (BOOL)handlesKeyDown:(NSEvent *)event inWindow:(NSWindow *)window
{
	if ([[event characters] isEqualToString:@"\033"]) {
		[self hidePanel];
		return YES;
	}
	
	return NO;
}

- (void)mouseDown:(NSEvent *)event
{
	[self hidePanel];
}

- (void)dealloc
{
	[_aboutPanel release];
	[_viewController release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

@end
