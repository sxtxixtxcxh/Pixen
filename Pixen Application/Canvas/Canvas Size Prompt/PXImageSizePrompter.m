//
//  PXImageSizePrompter.m
//  Pixel Editor
//
//  PXImageSizePrompter.m
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

//  Created by Joe Osborn on Tue Oct 28 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//
//
//  Created by Open Sword Group on Thu May 01 2003.
//  Copyright (c) 2003 Open Sword Group. All rights reserved.
//

#import "PXImageSizePrompter.h"
#import "PXCanvasView.h"
#import "PXNamePrompter.h"
#import "PXNSImageView.h"
#import "PXBackgrounds.h"
#import "PXPresetsManager.h"
#import "PXPreset.h"
#import "PXManagePresetsController.h"

@interface PXImageSizePrompter ()

- (void)populatePresetsButton;
- (void)updateSizeIndicators;

- (NSImage *)imageWithWidth:(CGFloat)width height:(CGFloat)height;

@end


@implementation PXImageSizePrompter

@synthesize width = _width, height = _height, backgroundColor;
@dynamic size;

- (id)init
{
	self = [super initWithWindowNibName:@"PXImageSizePrompt"];
	[self setBackgroundColor:[NSColor clearColor]];
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[backgroundColor release];
	[image release];
	[manageWC release];
	[super dealloc];
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	[[self window] setDelegate:self];
	[self populatePresetsButton];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(presetsChanged:)
												 name:PXPresetsChangedNotificationName
											   object:nil];
}

- (void)presetsChanged:(NSNotification *)notification
{
	[self populatePresetsButton];
}

- (void)windowWillClose:(NSNotification *)notification
{
	[self cancel:nil];
}

- (void)populatePresetsButton
{
	PXPresetsManager *manager = [PXPresetsManager sharedPresetsManager];
	NSMenu *menu = [presetsButton menu];
	
	[menu removeAllItems];
	[menu addItemWithTitle:@"Preset" action:NULL keyEquivalent:@""];
	
	for (NSString *name in [manager presetNames]) {
		[menu addItemWithTitle:name
						action:@selector(selectedPreset:)
				 keyEquivalent:@""];
	}
	
	if ([menu numberOfItems] > 1) {
		[menu addItem:[NSMenuItem separatorItem]];
	}
	
	[menu addItemWithTitle:@"Save Preset As..."
					action:@selector(savePresetAs:)
			 keyEquivalent:@""];
	
	[menu addItemWithTitle:@"Manage Presets..."
					action:@selector(managePresets:)
			 keyEquivalent:@""];
}

- (void)selectedPreset:(id)sender
{
	NSString *name = [presetsButton titleOfSelectedItem];
	PXPreset *preset = [[PXPresetsManager sharedPresetsManager] presetWithName:name];
	
	self.width = preset.size.width;
	self.height = preset.size.height;
	self.backgroundColor = preset.color;
	
	[self sizeChanged:nil];
}

- (void)savePresetAs:(id)sender
{
	if (!prompter) {
		prompter = [[PXNamePrompter alloc] init];
		prompter.delegate = self;
	}
	
	[prompter promptInWindow:[self window]
					 context:NULL
				promptString:@"Enter a name for this preset:"
				defaultEntry:@""];
}

- (void)managePresets:(id)sender
{
	if (!manageWC) {
		manageWC = [[PXManagePresetsController alloc] init];
	}
	
	[NSApp beginSheet:[manageWC window]
	   modalForWindow:[self window]
		modalDelegate:nil didEndSelector:NULL
		  contextInfo:NULL];
}

- (void)prompter:(id)aPrompter didFinishWithName:(NSString *)aName context:(id)context
{
	[[PXPresetsManager sharedPresetsManager] savePresetWithName:aName
														   size:self.size
														  color:backgroundColor];
}

- (IBAction)changedColor:(id)sender
{
	[image release];
	image = nil;
	
	[preview setImage:[self imageWithWidth:self.width height:self.height]];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.backgroundColor]
											  forKey:PXDefaultNewDocumentBackgroundColor];
}

- (NSImage *)imageWithWidth:(CGFloat)width height:(CGFloat)height
{
	if (image)
		return image;
	
	NSSize imageSize;
	
	if (width > height)
	{
		imageSize.width = MIN(85, width);
		imageSize.height = MAX(MIN(85, width) * (height / width), 1);
	}
	else
	{
		imageSize.height = MIN(85, height);
		imageSize.width = MAX(MIN(85, height) * (width / height), 1);
	}
	
	if (imageSize.width == 0 || imageSize.height == 0)
		return nil;
	
	image = [[NSImage alloc] initWithSize:imageSize];
	[image lockFocus];
	
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:PXCanvasDefaultMainBackgroundKey];
	
	PXBackground *background = (data) ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : [[[PXSlashyBackground alloc] init] autorelease];
	NSSize ceiledSize = NSMakeSize(ceilf(imageSize.width), ceilf(imageSize.height));
	[background drawRect:(NSRect){NSZeroPoint, ceiledSize} withinRect:(NSRect){NSZeroPoint, ceiledSize}];
	
	[backgroundColor set];
	NSRectFillUsingOperation(NSMakeRect(0, 0, imageSize.width, imageSize.height), NSCompositeSourceOver);
	
	[image unlockFocus];
	
	return image;
}

- (void)updateFieldsFromDefaults
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (![defaults objectForKey:PXDefaultNewDocumentWidth])
		[defaults setInteger:64 forKey:PXDefaultNewDocumentWidth];
	
	if (![defaults objectForKey:PXDefaultNewDocumentHeight])
		[defaults setInteger:64 forKey:PXDefaultNewDocumentHeight];
	
	if (![defaults objectForKey:PXDefaultNewDocumentBackgroundColor])
		[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor clearColor]] forKey:PXDefaultNewDocumentBackgroundColor];
	
	[self setBackgroundColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:PXDefaultNewDocumentBackgroundColor]]];
	
	self.width = [defaults integerForKey:PXDefaultNewDocumentWidth];
	self.height = [defaults integerForKey:PXDefaultNewDocumentHeight];
}

- (void)updateSizeIndicators
{
	NSSize imageSize = [image size];
	NSRect functionalRect = [preview functionalRect];
	
	if (NSIsEmptyRect(initialWidthIndicatorFrame)) {
		initialWidthIndicatorFrame = [widthIndicator frame];
	}
	
	[widthIndicator setFrame:NSMakeRect(NSMinX(functionalRect) + NSMinX([preview frame]),
										NSMinY([widthIndicator frame]),
										imageSize.width, NSHeight([widthIndicator frame]))];
	
	if (NSIsEmptyRect(initialHeightIndicatorFrame)) {
		initialHeightIndicatorFrame = [heightIndicator frame];
	}
	
	[heightIndicator setFrame:NSMakeRect(NSMinX([heightIndicator frame]),
										 NSMinY(functionalRect) + NSMinY([preview frame]),
										 NSWidth([heightIndicator frame]), imageSize.height)];
	
	[[[self window] contentView] setNeedsDisplay:YES];
}

- (BOOL)runModal
{
	[self window];
	[self updateFieldsFromDefaults];
	
	[image release];
	image = nil;
	
	[preview setImage:[self imageWithWidth:self.width height:self.height]];
	[self updateSizeIndicators];
	
	initialSize = targetSize = [self size];
	
	animationTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05f
													   target:self
													 selector:@selector(updatePreviewImageFrame:)
													 userInfo:nil
													  repeats:YES] retain];
	
	[[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSRunLoopCommonModes];
	
	[NSApp runModalForWindow:[self window]];
	
	return accepted;
}

- (void)updatePreviewImageFrame:event
{
	NSSize previewSize = initialSize;
	
	CGFloat projectedFraction = (sin(animationFraction) + 1.0)/2.0 - 0.01; // the 0.01 is so it goes below 0
	
	if (projectedFraction < 0)
		return;
	
	previewSize.width = targetSize.width * (1.0 - projectedFraction) + initialSize.width * projectedFraction;
	previewSize.height = targetSize.height * (1.0 - projectedFraction) + initialSize.height * projectedFraction;
	
	[image release];
	image = nil;
	
	[preview setImage:[self imageWithWidth:previewSize.width height:previewSize.height]];
	[self updateSizeIndicators];
	
	// [preview setFunctionalRect:previewRect];
	[preview setNeedsDisplay];
	
	animationFraction -= 0.25;
}

- (NSSize)size
{
	return NSMakeSize(_width, _height);
}

- (IBAction)sizeChanged:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:self.width forKey:PXDefaultNewDocumentWidth];
	[[NSUserDefaults standardUserDefaults] setInteger:self.height forKey:PXDefaultNewDocumentHeight];
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.backgroundColor] forKey:PXDefaultNewDocumentBackgroundColor];
	
	[image release];
	image = nil;
	
	initialSize = [preview functionalRect].size;
	targetSize = [preview scaledSizeForImage:[self imageWithWidth:self.width height:self.height]];
	
	animationFraction = 1;
}

- (void)controlTextDidChange:(NSNotification *)notification
{
	if (self.width == 0)
	{
		NSBeep();
		self.width = 1;
	}
	
	if (self.height == 0)
	{
		NSBeep();
		self.height = 1;
	}
	
	[self sizeChanged:self];
}

- (IBAction)useEnteredSize:(id)sender
{
	[[self window] makeFirstResponder:nil];
	
	if (animationTimer)
		[animationTimer invalidate];
	
	[animationTimer release];
	animationTimer = nil;
	
	accepted = YES;
	
	[[self window] orderOut:nil];
	[NSApp stopModal];
}

- (IBAction)cancel:(id)sender
{	
	accepted = NO;
	
	[[self window] orderOut:nil];
	[NSApp stopModal];
}

@end
