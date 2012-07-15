//
//  PXAboutWindowController.m
//  Pixen
//
//  Copyright 2005-2012 Pixen Project. All rights reserved.
//

#import "PXAboutWindowController.h"

@implementation PXAboutWindowController

@synthesize webView = _webView;

+ (id)sharedController
{
	static PXAboutWindowController *singleInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		singleInstance = [[self alloc] init];
	});
	
	return singleInstance;
}

- (id)init
{
	return [super initWithWindowNibName:@"PXAbout"];
}

- (void)awakeFromNib
{
	[_webView setPolicyDelegate:self];
	
	NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:CFBundleShortVersionKey];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"];
	
	NSString *string = [[NSString alloc] initWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil];
	NSString *contents = [string stringByReplacingOccurrencesOfString:@"VERSION_PLACEHOLDER" withString:version];
	
	NSURL *baseURL = [[NSBundle mainBundle] resourceURL];
	
	[[_webView mainFrame] loadHTMLString:contents baseURL:baseURL];
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation
		request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
	NSURL *url = [request URL];
	
	if ([url host] || [[url scheme] isEqualToString:@"mailto"]) {
		[[NSWorkspace sharedWorkspace] openURL:url];
	}
	else {
		[listener use];
	}
}

@end
