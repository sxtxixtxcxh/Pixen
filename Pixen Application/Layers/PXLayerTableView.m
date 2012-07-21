//
//  PXLayerTableView.m
//  Pixen
//
//  Copyright 2012 Pixen Project. All rights reserved.
//

#import "PXLayerTableView.h"

#import "PXLayerTextField.h"

@implementation PXLayerTableView

- (BOOL)acceptsFirstResponder
{
	return NO;
}

- (BOOL)validateProposedFirstResponder:(NSResponder *)responder forEvent:(NSEvent *)event
{
	if ([responder isKindOfClass:[PXLayerTextField class]])
		return YES;
	
	return [super validateProposedFirstResponder:responder forEvent:event];
}

@end
