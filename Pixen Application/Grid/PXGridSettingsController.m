//
//  PXGridSettingsController.m
//  Pixen-XCode
//
// Copyright (c) 2003,2004,2005 Open Sword Group

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
//  Created by Andy Matuschak on Thu Mar 18 2004.
//  Copyright (c) 2004 Open Sword Group. All rights reserved.
//

#import "PXGridSettingsController.h"
#import "PXDefaults.h"

@implementation PXGridSettingsController

@synthesize width, height, color, shouldDraw, delegate;

- (id)init
{
	if ( ! ( self = [super initWithWindowNibName:@"PXGridSettings"] ))
		return nil;
	
	return self;
}

- (void)showWindow:(id)sender
{
	[super showWindow:sender];
	[self update:nil];
}

- (IBAction)update:(id)sender
{
	if ([shouldDrawCheckBox state] == NSOnState) {
		[sizeLabel setTextColor:[NSColor blackColor]];
		[colorLabel setTextColor:[NSColor blackColor]];
	} else {
		if ([colorWell isActive])
			[[NSColorPanel sharedColorPanel] close];
		
		[sizeLabel setTextColor:[NSColor disabledControlTextColor]];
		[colorLabel setTextColor:[NSColor disabledControlTextColor]];
	}
	
	[delegate gridSettingsController:self
					 updatedWithSize:NSMakeSize(self.width, self.height)
							   color:self.color
						  shouldDraw:self.shouldDraw];
}

- (IBAction)useAsDefaults:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setBool:self.shouldDraw forKey:PXGridShouldDrawKey];
	[defaults setFloat:self.width forKey:PXGridUnitWidthKey];
	[defaults setFloat:self.height forKey:PXGridUnitHeightKey];
	[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.color]
				 forKey:PXGridColorDataKey];
	
	[self update:self];
}

- (IBAction)displayHelp:(id)sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"grid" inBook:@"Pixen Help"];
}

- (void)windowWillClose:(NSNotification *)notification
{
	if ([colorWell isActive])
	{
		[[NSColorPanel sharedColorPanel] close];
	}
}

@end
