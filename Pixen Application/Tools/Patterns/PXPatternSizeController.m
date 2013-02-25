//
//  PXPatternSizeController.m
//  Pixen
//
//  Created by Matt on 2/25/13.
//
//

#import "PXPatternSizeController.h"

@implementation PXPatternSizeController

- (id)init
{
	self = [super initWithWindowNibName:@"PXPatternSizeWindow"];
	if (self) {
		
	}
	return self;
}

- (void)runSheetModalForParentWindow:(NSWindow *)parentWindow
{
	[NSApp beginSheet:[self window] modalForWindow:parentWindow modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
	[NSApp runModalForWindow:[self window]];
	
	[NSApp endSheet:[self window]];
	[[self window] orderOut:nil];
}

- (void)create:(id)sender
{
	[NSApp stopModal];
}

- (int)width
{
	return [self.widthField intValue];
}

- (int)height
{
	return [self.heightField intValue];
}

@end
