//
//  PXBuiltinBackgroundTemplateView.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXBuiltinBackgroundTemplateView.h"

#import "PXBackgrounds.h"

@implementation PXBuiltinBackgroundTemplateView

- (void)setBackground:(PXBackground *)bg
{
	[super setBackground:bg];
	
	[self.templateNameField setStringValue:[bg defaultName]];
	[self.templateClassNameField setStringValue:NSLocalizedString(@"Built-in Template", @"Built-in Template")];
}

@end
