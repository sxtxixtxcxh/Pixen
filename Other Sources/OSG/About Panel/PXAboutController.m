//
//  PXAboutController.h
//  Pixen
//
//  Copyright 2005-2011 Pixen Project. All rights reserved.
//

#import "PXAboutController.h"

#import "Constants.h"
#import "PXAboutPanel.h"

#import <QuartzCore/QuartzCore.h>

@interface PXAboutController ()

- (PXAboutPanel *)aboutPanel;

- (void)watchForNotificationsWhichShouldHidePanel;

@end


@implementation PXAboutController {
	PXAboutPanel *_aboutPanel;
}

@synthesize creditsView = _creditsView, versionField = _versionField;

- (id)init
{
	return [super initWithWindowNibName:@"PXAbout"];
}

+ (id)sharedAboutController
{
	static PXAboutController *singleInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		singleInstance = [[self alloc] init];
	});
	
	return singleInstance;
}

- (void)loadCreditsText
{
	NSString *creditsPath = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"];
	NSData *htmlData = [NSData dataWithContentsOfFile:creditsPath];
	
	if (!htmlData)
		return;
	
	NSDictionary *attributedOptions = [NSDictionary dictionaryWithObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]
																  forKey:NSBaseURLDocumentOption];
	
	NSAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithHTML:htmlData
																				   options:attributedOptions
																		documentAttributes:nil];
	
	[[self.creditsView textStorage] setAttributedString:attributedString];
	[attributedString release];
	
	NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey: (NSString *) kCFBundleVersionKey];
	version = [@"Version " stringByAppendingString:version];
	
	[self.versionField setStringValue:version];
}

- (PXAboutPanel *)aboutPanel
{
	if (!_aboutPanel) {
		_aboutPanel = [[PXAboutPanel alloc] initWithContentRect:[ (NSView *) [self.window contentView] frame]
													  styleMask:NSBorderlessWindowMask
														backing:[self.window backingType]
														  defer:NO];
		
		[_aboutPanel setBackgroundColor:[NSColor whiteColor]];
		[_aboutPanel setHasShadow:YES];
		[_aboutPanel setNextResponder:self];
		[_aboutPanel setBecomesKeyOnlyIfNeeded:NO];
		[_aboutPanel setDelegate:self];
		[_aboutPanel setLevel:NSModalPanelWindowLevel];
		
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"alphaValue"];
		animation.delegate = self;
		
		[_aboutPanel setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"alphaValue"]];
		
		NSView *content = [[self.window contentView] retain];
		[content removeFromSuperview];
		
		[_aboutPanel setContentView:content];
		[content release];
		
		[_aboutPanel center];
		
		[self loadCreditsText];
		[self watchForNotificationsWhichShouldHidePanel];
	}
	
	return _aboutPanel;
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

- (void)dealloc
{
	[_aboutPanel release];
	[_versionField release];
	[_creditsView release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void)showPanel:(id)sender
{
	PXAboutPanel *panel = [self aboutPanel];
	
	[panel setAlphaValue:0.0f];
	[panel makeKeyAndOrderFront:nil];
	
	[[panel animator] setAlphaValue:1.0f];
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

@end
