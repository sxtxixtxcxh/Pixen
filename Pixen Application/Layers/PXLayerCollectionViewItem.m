//
//  PXLayerCollectionViewItem.m
//  Pixen
//
//  Created by Joseph C Osborn on 2011.06.15.
//  Copyright 2011 Universal Happy-Maker. All rights reserved.
//

#import "PXLayerCollectionViewItem.h"

#import "PXCanvas.h"
#import "PXCanvas_CopyPaste.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_Modifying.h"
#import "PXLayer.h"
#import "PXLayerController.h"
#import "PXLayerDetailsView.h"
#import "PXLayerTextField.h"
#import "PXNSImageView.h"

@interface PXLayerCollectionViewItem ()

- (void)setupMenu;
- (void)updatePreview:(NSNotification *)notification;

@end


@implementation PXLayerCollectionViewItem

@synthesize backgroundView = _backgroundView;
@synthesize layerController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ( ! (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
		return nil;
	
	[self setSelected:NO];
	
	return self;
}

- (id)init
{
	return [self initWithNibName:@"PXLayerDetailsView" bundle:nil];
}

- (void)awakeFromNib
{
	[thumbnailView setEditable:NO];
	[self setupMenu];
}

- (void)setRepresentedObject:(id)representedObject
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[super setRepresentedObject:representedObject];
	
	layer = nil;
	
	if ([self representedObject]) {
		layer = [self representedObject];
		
		[nc addObserver:self
			   selector:@selector(updatePreview:)
				   name:PXCanvasChangedNotificationName
				 object:[layer canvas]];
	}
}

- (void)dealloc
{
	[self unload];
	[super dealloc];
}

- (void)focusOnName
{
	[[self.view window] makeKeyAndOrderFront:nil];
	[nameField useEditAppearance];
	[[self.view window] makeFirstResponder:nameField];
}

- (NSString *)degreeString
{
	UniChar degree[] = { 0x00B0 };
	return [NSString stringWithCharacters:degree length:1];
}

- (void)setupMenu
{
	NSMenu *menu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Layer", @"Layer")];
	
	NSMenuItem *item;
	
	item = [[[NSMenuItem alloc] init] autorelease];
	[item setTitle:NSLocalizedString(@"Delete", @"Delete")];
	[item setAction:@selector(delete:)];
	[item setTarget:self];
	[menu addItem:item];
	
	item = [[[NSMenuItem alloc] init] autorelease];
	[item setTitle:NSLocalizedString(@"Duplicate", @"Duplicate")];
	[item setAction:@selector(duplicate:)];
	[item setTarget:self];
	[menu addItem:item];
	
	item = [[[NSMenuItem alloc] init] autorelease];
	[item setTitle:NSLocalizedString(@"Merge Down", @"Merge Down")];
	[item setAction:@selector(mergeDown:)];
	[item setTarget:self];
	[menu addItem:item];
	
	[menu addItem:[NSMenuItem separatorItem]];
	
	item = [[[NSMenuItem alloc] init] autorelease];
	[item setTitle:NSLocalizedString(@"Cut", @"Cut")];
	[item setAction:@selector(cutLayer:)];
	[item setTarget:self];
	[menu addItem:item];
	
	item = [[[NSMenuItem alloc] init] autorelease];
	[item setTitle:NSLocalizedString(@"Copy", @"Copy")];
	[item setAction:@selector(copyLayer:)];
	[item setTarget:self];
	[menu addItem:item];		
	
	NSMenu *subMenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Transform Layer", @"Transform Layer")];
	
	NSMenuItem *subMenuItem = [[[NSMenuItem alloc] init] autorelease];
	[subMenuItem setTitle:NSLocalizedString(@"Transform Layer", @"Transform Layer")];
	
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItem:subMenuItem];
	
	[menu setSubmenu:subMenu forItem:subMenuItem];
	[subMenu release];
	
	item = [[[NSMenuItem alloc] init] autorelease];
	[item setTitle:NSLocalizedString(@"Flip Horizontally", @"Flip Horizontally")];
	[item setAction:@selector(flipLayerHorizontally:)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	item = [[[NSMenuItem alloc] init] autorelease];
	[item setTitle:NSLocalizedString(@"Flip Vertically", @"Flip Vertically")];
	[item setAction:@selector(flipLayerVertically:)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	[subMenu addItem:[NSMenuItem separatorItem]];
	
	item = [[[NSMenuItem alloc] init] autorelease];
	[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rotate 90%@ Left", @"Rotate 90%@ Left"), [self degreeString]]];
	[item setAction:@selector(rotateLayerCounterclockwise:)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	item = [[[NSMenuItem alloc] init] autorelease];
	[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rotate 90%@ Right", @"Rotate 90%@ Right"), [self degreeString]]];
	[item setAction:@selector(rotateLayerClockwise:)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	item = [[[NSMenuItem alloc] init] autorelease];
	[item setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rotate 180%@", @"Rotate 180%@"), [self degreeString]]];
	[item setAction:@selector(rotateLayer180:)];
	[item setTarget:self];
	[subMenu addItem:item];
	
	[self.view setMenu:menu];
	[menu release];
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	if ([anItem action] == @selector(mergeDown:)) {
		NSArray *layers = [[layerController canvas] layers];
		return [layers count] > 1 && [layers objectAtIndex:0] != layer;
	}
	else if ([anItem action] == @selector(cutLayer:) || [anItem action] == @selector(delete:)) {
		NSArray *layers = [[layerController canvas] layers];
		return [layers count] > 1;
	}
	
	return YES;
}

- (void)unload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)updatePreviewReal
{
	[thumbnailView setImage:[layer displayImage]];
	[thumbnailView setNeedsDisplay:YES];
}

- (void)updatePreview:(NSNotification *)notification
{
	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(updatePreviewReal) object:nil];
	[self performSelector:@selector(updatePreviewReal) withObject:nil afterDelay:0.05f];
}

- (void)delete:(id)sender
{
	[layerController removeLayerObject:layer];
}

- (void)duplicate:(id)sender
{
	[layerController duplicateLayerObject:layer];
}

- (void)mergeDown:(id)sender
{
	[layerController mergeDownLayerObject:layer];
}

- (void)cutLayer:(id)sender
{
	[layerController cutLayerObject:layer];
}

- (void)copyLayer:(id)sender
{
	[layerController copyLayerObject:layer];
}

- (void)rotateLayerCounterclockwise:(id)sender
{
	[[layer canvas] rotateLayer:layer byDegrees:90];
}

- (void)rotateLayerClockwise:(id)sender
{
	[[layer canvas] rotateLayer:layer byDegrees:270];
}

- (void)rotateLayer180:(id)sender
{
	[[layer canvas] rotateLayer:layer byDegrees:180];
}

- (void)flipLayerHorizontally:(id)sender
{
	[[layer canvas] flipLayerHorizontally:layer];
}

- (void)flipLayerVertically:(id)sender
{
	[[layer canvas] flipLayerVertically:layer];
}

- (void)setSelected:(BOOL)state
{
	[super setSelected:state];
	
	if (state) {
		[[nameField cell] setBackgroundStyle:NSBackgroundStyleLowered];
		[[opacityField cell] setBackgroundStyle:NSBackgroundStyleLowered];
		
		if (nameField.isEditing) {
			[[nameField cell] setTextColor:[NSColor blackColor]];
		}
		else {
			[[nameField cell] setTextColor:[NSColor whiteColor]];
		}
		
		[[opacityField cell] setTextColor:[NSColor whiteColor]];
	}
	else {
		[[nameField cell] setBackgroundStyle:NSBackgroundStyleLight];
		[[opacityField cell] setBackgroundStyle:NSBackgroundStyleLight];
		
		[[nameField cell] setTextColor:[NSColor blackColor]];
		[[opacityField cell] setTextColor:[NSColor grayColor]];
	}
	
	[_backgroundView setSelected:state];
}

@end
