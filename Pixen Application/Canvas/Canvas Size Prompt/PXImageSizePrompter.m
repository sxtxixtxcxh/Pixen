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
#import "PXNSImageView.h"
#import "PXBackgrounds.h"

@interface PXImageSizePrompter ()

- (NSImage *)imageWithWidth:(CGFloat)width height:(CGFloat)height;

@end


@implementation PXImageSizePrompter

@synthesize size, backgroundColor;

- (id)init
{
	self = [super initWithWindowNibName:@"PXImageSizePrompt"];
	[self setBackgroundColor:[NSColor clearColor]];
	return self;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"backgroundColor"];
	[self setBackgroundColor:nil];
	[image release];
	[super dealloc];
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	[[self window] setDelegate:self];
	
	[self addObserver:self 
		   forKeyPath:@"backgroundColor"
			  options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
			  context:NULL];
}

- (void)windowWillClose:(NSNotification *)notification
{
	[self cancel:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"backgroundColor"]) {
		[image release];
		image = nil;
		
		[preview setImage:[self imageWithWidth:size.width height:size.height]];
	}
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
	
	[widthField setIntegerValue:[defaults integerForKey:PXDefaultNewDocumentWidth]];
	[heightField setIntegerValue:[defaults integerForKey:PXDefaultNewDocumentHeight]];
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
	
	CGFloat width = [widthField integerValue], height = [heightField integerValue];
	
	[image release];
	image = nil;
	
	[preview setImage:[self imageWithWidth:width height:height]];
	[self updateSizeIndicators];
	
	initialSize = NSMakeSize(width, height);
	targetSize = initialSize;
	
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

- (IBAction)sizeChanged:sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:[widthField intValue] forKey:PXDefaultNewDocumentWidth];
	[[NSUserDefaults standardUserDefaults] setInteger:[heightField intValue] forKey:PXDefaultNewDocumentHeight];
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:backgroundColor] forKey:PXDefaultNewDocumentBackgroundColor];
	
	[image release];
	image = nil;
	
	CGFloat width = [widthField integerValue];
	CGFloat height = [heightField integerValue];
	
	size = NSMakeSize(width, height);
	initialSize = [preview functionalRect].size;
	targetSize = [preview scaledSizeForImage:[self imageWithWidth:width height:height]];
	
	animationFraction = 1;
}

- (void)controlTextDidChange:note
{
	if ([widthField integerValue] == 0)
	{
		NSBeep();
		[widthField setIntegerValue:1];
	}
	
	if ([heightField integerValue] == 0)
	{
		NSBeep();
		[heightField setIntegerValue:1];
	}
	
	[self sizeChanged:self];
}

- (IBAction)useEnteredSize:(id)sender
{
	[[self window] makeFirstResponder:nil];
	
	NSInteger width = MAX([widthField integerValue], 1);
	NSInteger height = MAX([heightField integerValue], 1);
	
	size = NSMakeSize(width, height);
	
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
