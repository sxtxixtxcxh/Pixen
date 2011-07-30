//
//  PXBuiltinBackgroundTemplateView.m
//  Pixen
//
//  Created by Andy Matuschak on 7/5/05.
//  Copyright 2005 Pixen. All rights reserved.
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
