//
//  PXAboutController.m
//  Pixen-XCode
//
//  Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use,copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM,  OUT OF OR IN CONNECTION WITH
// THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//  Created by Andy Matuschak on Sun Aug 01 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXAboutController.h"

#import "Constants.h"
#import "PXAboutPanel.h"

#import <QuartzCore/QuartzCore.h>

@implementation PXAboutController

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
	
	if (!htmlData) {
		return;
	}
	
	NSDictionary *attributedOptions = [NSDictionary dictionaryWithObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]
																  forKey:NSBaseURLDocumentOption];
	
	NSAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithHTML:htmlData
																				   options:attributedOptions
																		documentAttributes:nil];
	
	[[creditsView textStorage] setAttributedString:attributedString];
	[attributedString release];
	
	NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleVersionKey];
	version = [@"Version " stringByAppendingString:version];
	
	[versionField setStringValue:version];
}

- (void)createPanel
{
	aboutPanel = [[PXAboutPanel alloc] initWithContentRect:[ (NSView *) [self.window contentView] frame]
												 styleMask:NSBorderlessWindowMask
												   backing:[self.window backingType]
													 defer:NO];
	
	[aboutPanel setBackgroundColor:[NSColor whiteColor]];
	[aboutPanel setHasShadow:YES];
	[aboutPanel setNextResponder:self];
	[aboutPanel setBecomesKeyOnlyIfNeeded:NO];
	[aboutPanel setDelegate:self];
	[aboutPanel setLevel:NSModalPanelWindowLevel];
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"alphaValue"];
	animation.delegate = self;
	
	[aboutPanel setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"alphaValue"]];
	
	NSView *content = [[self.window contentView] retain];
	[content removeFromSuperview];
	
	[aboutPanel setContentView:content];
	[content release];
}

//Watch for notifications that the application is no longer active, or that
//another window has replaced the About panel as the main window, and hide
//on either of these notifications.
- (void)watchForNotificationsWhichShouldHidePanel
{
	//This works better than just making the panel hide when the app
	//deactivates (setHidesOnDeactivate:YES), because if we use that
	//then the panel will return when the app reactivates.
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(hidePanel)
			   name:NSApplicationDidResignActiveNotification
			 object:nil];
	
	//If the panel is no longer main, hide it.
	//(We could also use the delegate notification for this.)
	[nc addObserver:self
		   selector:@selector(hidePanel)
			   name:NSWindowDidResignMainNotification
			 object:aboutPanel];
	
	[nc addObserver:self
		   selector:@selector(hidePanel)
			   name:NSWindowDidResignKeyNotification
			 object:aboutPanel];
	
}

- (void)dealloc
{
	[aboutPanel release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)setupPanel
{
	[self createPanel];
	[self loadCreditsText];
	[aboutPanel center];
	[self watchForNotificationsWhichShouldHidePanel];
}

- (void)showPanel:(id)sender
{
	if (!aboutPanel)
		[self setupPanel];
	
	[aboutPanel setAlphaValue:0.0];
	[aboutPanel makeKeyAndOrderFront:nil];
	
	[[aboutPanel animator] setAlphaValue:1.0f];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
	if ([aboutPanel alphaValue] == 0)
		[aboutPanel orderOut:nil];
}

- (void)hidePanel
{
	[[aboutPanel animator] setAlphaValue:0.0f];
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
