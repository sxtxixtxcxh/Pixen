//
//  PXAboutController.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXAboutController.h"

/*
@interface PXAboutController ()

- (void)loadCreditsText;

@end
 */


@implementation PXAboutController

@synthesize webView = _webView;

- (id)init
{
	return [super initWithNibName:@"PXAbout" bundle:nil];
}

/*
- (void)awakeFromNib
{
	[self loadCreditsText];
}

- (void)loadCreditsText
{
	NSString *creditsPath = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"];
	NSData *htmlData = [NSData dataWithContentsOfFile:creditsPath];
	
	if (!htmlData)
		return;
	
	NSAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithHTML:htmlData
																				   options:nil
																		documentAttributes:nil];
	
	[[self.creditsView textStorage] setAttributedString:attributedString];
	[attributedString release];
	
	NSString *versionNum = [[[NSBundle mainBundle] infoDictionary] valueForKey:CFBundleShortVersionKey];
	NSString *version = [NSString stringWithFormat:NSLocalizedString(@"VERSION_STRING", nil), versionNum];
	
	[self.versionField setStringValue:version];
}
 */

@end
