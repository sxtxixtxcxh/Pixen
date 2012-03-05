//
//  PXAboutController.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXAboutController.h"

@implementation PXAboutController

@synthesize webView = _webView;

- (id)init
{
	return [super initWithNibName:@"PXAbout" bundle:nil];
}

- (void)awakeFromNib
{
	NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:CFBundleShortVersionKey];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"];
	
	NSString *string = [[NSString alloc] initWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil];
	string = [string stringByReplacingOccurrencesOfString:@"VERSION_PLACEHOLDER" withString:version];
	
	NSURL *baseURL = [[NSBundle mainBundle] resourceURL];
	
	[[_webView mainFrame] loadHTMLString:string baseURL:baseURL];
}

@end
