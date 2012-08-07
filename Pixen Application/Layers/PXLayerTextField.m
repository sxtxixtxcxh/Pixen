//
//  PXLayerTextField.m
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "PXLayerTextField.h"

@implementation PXLayerTextField {
	BOOL _isEditing;
}

- (void)awakeFromNib {
	[self setDelegate:self];
}

- (void)mouseDown:(NSEvent *)theEvent {
	if ([theEvent clickCount] == 2 && !_isEditing) {
		[self beginEditing];
	}
	else {
		[super mouseDown:theEvent];
	}
}

- (void)beginEditing {
	_isEditing = YES;
	
	[self setEditable:YES];
	[self setDrawsBackground:YES];
	[self setBackgroundColor:[NSColor whiteColor]];
	[self setSelectable:YES];
	
	[self selectText:nil];
	
	[self setNeedsDisplay:YES];
}

- (void)endEditing {
	[self setEditable:NO];
	[self setDrawsBackground:NO];
	[self setBackgroundColor:[NSColor clearColor]];
	[self setSelectable:NO];
	
	[self setNeedsDisplay:YES];
	
	_isEditing = NO;
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
	[self endEditing];
}

@end
