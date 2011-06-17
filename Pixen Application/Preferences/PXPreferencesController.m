//
//  PXPreferencesController.m
//  Pixen-XCode

// Copyright (c) 2003,2004,2005 Open Sword Group

// Permission is hereby granted, free of charge, to any person obtaining a copy

// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation 
// the rights  to use,copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom
//  the Software is  furnished to do so, subject to the following conditions:

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
//  Created by Matt Rajca on Fri Jun 17 2011.
//  Copyright (c) 2011 Open Sword Group. All rights reserved.
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
