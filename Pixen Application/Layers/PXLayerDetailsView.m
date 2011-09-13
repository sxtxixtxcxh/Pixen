//
//  PXLayerDetailsView.m
//  Pixen
//

#import "PXLayerDetailsView.h"
#import "PXLayer.h"
#import "PXCanvas.h"
#import "PXCanvas_Layers.h"
#import "PXCanvas_CopyPaste.h"
#import "PXCanvas_Modifying.h"
#import "PXNotifications.h"
#import "PXLayerTextField.h"
#import "PXNSImageView.h"
#import "PXLayerController.h"

#import <Foundation/NSNotification.h>


@implementation PXLayerDetailsView

@synthesize selected;

-(id) initWithLayer:(PXLayer *)aLayer
{
	if ( ! (self = [super init] ) ) 
		return nil;
	
	[NSBundle loadNibNamed:@"PXLayerDetailsView" owner:self];
	self.selected = NO;
  [self setAutoresizesSubviews:YES];
	[self addSubview:view];
	[self setLayer:aLayer];
	[thumbnail setEditable:NO];
	isHidden = YES;
	return self;
}

- (BOOL)acceptsFirstResponder {
	return NO;
}

- (void)setFrame:(NSRect)newFrame
{
	[super setFrame:newFrame];
	[view setFrameSize:[self frame].size];
}

- (void)resizeWithOldSuperviewSize:(NSSize)size
{
	[self setFrameSize:NSMakeSize(NSWidth([[self superview] frame]), NSHeight([self frame]))];
}

- (void)resizeSubviewsWithOldSize:(NSSize)size
{
	[view setFrameSize:[self frame].size];
}

- opacityText
{
	return opacityText;
}

- (NSTextField *)name
{
	return name;
}

- layer
{
	return layer;
}

- (void)focusOnName
{
	[[self window] makeKeyAndOrderFront:nil];
	[name useEditAppearance];
	[[self window] makeFirstResponder:name];
}

- (void)dealloc
{
	[[self class] cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- degreeString
{
	UniChar degree[] = { 0x00B0 };
	return [NSString stringWithCharacters:degree length:1];
}

- (void)setLayer:(PXLayer *)aLayer
{
	//set preview, name field, and other state
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc removeObserver:self];

	layer = aLayer;

	if(layer)
	{
		NSMenu *menu = [[[NSMenu alloc] initWithTitle:NSLocalizedString(@"Layer", @"Layer")] autorelease];
		NSMenuItem *item;
		
		item = [[[NSMenuItem alloc] init] autorelease];
		[item setTitle:NSLocalizedString(@"Delete", @"Delete")];
		[item setAction:@selector(delete:)];
    [item setKeyEquivalent:[NSString stringWithCharacters:(const unichar[]){NSDeleteCharacter} length:1]];
    [item setKeyEquivalentModifierMask:0];
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
		
		NSMenu *subMenu = [[[NSMenu alloc] initWithTitle:NSLocalizedString(@"Transform Layer", @"Transform Layer")] autorelease];
		NSMenuItem *subMenuItem = [[[NSMenuItem alloc] init] autorelease];
		[subMenuItem setTitle:NSLocalizedString(@"Transform Layer", @"Transform Layer")];
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItem:subMenuItem];
		[menu setSubmenu:subMenu forItem:subMenuItem];
		
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
		
		[view setMenu:menu];
		[name setMenu:menu];
		[opacity setMenu:menu];
		[visibility setMenu:menu];
		[opacityText setMenu:menu];
		[thumbnail setMenu:menu];
		
		[name setStringValue:[layer name]];
		[opacity setFloatValue:[layer opacity]];
		[self updatePreview:nil];
		[visibility setState:[layer visible]];
		[nc addObserver:self 
			   selector:@selector(updatePreview:) 
				   name:PXCanvasChangedNotificationName
				 object:[layer canvas]];
		
		[nc addObserver:self selector:@selector(paletteChanged:) name:PXPaletteChangedNotificationName object:nil];
	}
	[self setNeedsDisplay:YES];
}

- (void)paletteChanged:note
{
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

- (void)updatePreviewReal
{
	[thumbnail setImage:[layer displayImage]];
	[thumbnail setNeedsDisplay:YES];
}

- (void)updatePreview:(NSNotification* )notification
{
	[[self class] cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(updatePreviewReal) withObject:nil afterDelay:0.05f];
}

- (IBAction)visibilityDidChange:(id) sender
{
	[layer setVisible:([sender state] == NSOnState) ? YES : NO];
	[[layer canvas] changed];
}


- (BOOL)isHidden
{
	if([super respondsToSelector:@selector(isHidden)])
    {
		return [super isHidden];
    }
	return isHidden;
}

- (void)setHidden:(BOOL)newHidden
{
	if([self isHidden] == newHidden) 
	{
		return; 
	}
	
	if([super respondsToSelector:@selector(setHidden:)]) 
	{
		[super setHidden:newHidden]; 
	}
	
	isHidden = newHidden;
	[self updatePreview:nil];
}

- (void)rightMouseDown:(NSEvent *)event
{
	[view rightMouseDown:event];
}

- (IBAction)opacityDidChange:(id)sender
{
	[opacity setFloatValue:[sender floatValue]];
	[layer setOpacity:[sender floatValue]];
	[[layer canvas] changed];
}

- (IBAction)nameDidChange:(id)sender
{
	[(PXLayer *)layer setName:[name stringValue]];
}

- (void)setLayerController:cont
{
	layerController = cont;
}

- (void)delete:(id) sender
{
	[layerController removeLayerObject:layer];
}

- (void)duplicate:(id) sender
{
	[layerController duplicateLayerObject:layer];
}

- (void)mergeDown:(id) sender
{
	[layerController mergeDownLayerObject:layer];
}

- (void)cutLayer:sender
{
	[[layer canvas] cutLayer:layer];
}

- (void)copyLayer:sender
{
	[[layer canvas] copyLayer:layer toPasteboard:[NSPasteboard generalPasteboard]];
}

- (void)rotateLayerCounterclockwise:sender
{
	[[layer canvas] rotateLayer:layer byDegrees:90];
}

- (void)rotateLayerClockwise:sender
{
	[[layer canvas] rotateLayer:layer byDegrees:270];
}

- (void)rotateLayer180:sender
{
	[[layer canvas] rotateLayer:layer byDegrees:180];
}

- (IBAction)flipLayerHorizontally:(id) sender
{		
	[[layer canvas] flipLayerHorizontally:layer];
}

- (IBAction)flipLayerVertically:(id) sender
{
	[[layer canvas] flipLayerVertically:layer];
}

- (void)setSelected:(BOOL)state
{
	if (selected != state)
	{
		selected = state;
		
		if (selected) {
			if (name.isEditing) {
				[[name cell] setTextColor:[NSColor blackColor]];
			}
			else {
				[[name cell] setTextColor:[NSColor whiteColor]];
			}
			
			[[opacityText cell] setTextColor:[NSColor whiteColor]];
		}
		else {
			[[name cell] setTextColor:[NSColor blackColor]];
			[[opacityText cell] setTextColor:[NSColor grayColor]];
		}
		
		[self setNeedsDisplay:YES];
	}
}

- (void)drawRect:(NSRect)r {
	if (selected) {
		[[NSColor alternateSelectedControlColor] set];
		NSRectFill(r);
	}
}

@end
