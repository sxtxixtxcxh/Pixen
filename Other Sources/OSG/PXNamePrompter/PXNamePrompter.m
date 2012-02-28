//
//  PXNamePrompter.m
//  Pixen
//
//  Copyright 2004-2012 Pixen Project. All rights reserved.
//

#import "PXNamePrompter.h"
#import "PXCanvasView.h"

@implementation PXNamePrompter

@synthesize delegate = _delegate;

- (id)init
{
	if ( ! (self = [super initWithWindowNibName:@"PXNamePrompt"]))
		return nil;
	
	return self;
}

- (void)promptInWindow:(NSWindow *)window context:(id)contextInfo
{
	[self promptInWindow:window
				 context:contextInfo
			promptString:NSLocalizedString(@"Please name the new configuration.",
										   @"Please name the new configuration.")
			defaultEntry:@""];
}

- (void)promptInWindow:(NSWindow *)window
			   context:(id)contextInfo
		  promptString:(NSString *)string
		  defaultEntry:(NSString *)entry
{
	_context = contextInfo;
	
	[self loadWindow];
	
	[promptString setStringValue:string];
	[nameField setStringValue:entry];
	
	[NSApp beginSheet:self.window
	   modalForWindow:window
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}

+ (NSString *)promptModalWithPromptString:(NSString *)string
{
	return [[[[self alloc] init] autorelease] promptModalWithPromptString:string];
}

- (NSString *)promptModalWithPromptString:(NSString *)string
{
	_runningModal = YES;
	_modalString = nil;
	[promptString setStringValue:string];
	NSInteger result = [NSApp runModalForWindow:self.window];
	_runningModal = NO;
	[self.window close];
	if (result == NSRunAbortedResponse) {
		return nil;
	} else {
		return [nameField stringValue];
	}
}

//Action from 'use this entered name" button
//TODO probably warm the use if it is empty.
// Maybye do external check or use formater for nameField
- (IBAction)useEnteredName:(id)sender
{
	if ([[nameField stringValue] isEqualToString:@""]) {
		NSBeep();
		return;
	}
	
	if (_runningModal) {
		[NSApp stopModal];
		return;
	}
	
	if ([_delegate respondsToSelector:@selector(prompter:didFinishWithName:context:)])
		[_delegate prompter:self didFinishWithName:[nameField stringValue] context:_context];
	
	[NSApp endSheet:self.window];
	[self.window close];
}

//Action from 'use this entered name" button
//this method end the sheet (OSX), close the panel 
//and send prompter:didCancelWithContext: to the delegate
- (IBAction)cancel:(id)sender
{
	if (_runningModal) {
		[NSApp abortModal];
		return;
	}
	
	[NSApp endSheet:self.window];
	[self.window close];
	
	if ([_delegate respondsToSelector:@selector(prompter:didCancelWithContext:)])
		[_delegate prompter:self didCancelWithContext:_context];
}

@end
