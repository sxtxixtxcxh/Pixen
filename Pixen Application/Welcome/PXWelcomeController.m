//
//  PXWelcomeController.m
//  Pixen
//
//  Copyright 2011-2012 Pixen Project. All rights reserved.
//

#import "PXWelcomeController.h"

@implementation PXWelcomeController

@synthesize webView = _webView;

static NSString *const kLastPageURLKey = @"lastPageURL";

+ (PXWelcomeController *)sharedWelcomeController
{
	static PXWelcomeController *sharedWelcomeController = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedWelcomeController = [[self alloc] init];
	});
	
	return sharedWelcomeController;
}

- (id)init
{
	if ( ! ( self = [super initWithWindowNibName:@"PXDiscoverPixen"] ))
		return nil;
	
	return self;
}

+ (void)restoreWindowWithIdentifier:(NSString *)identifier state:(NSCoder *)state completionHandler:(void (^)(NSWindow *, NSError *))completionHandler {
	
	if ([identifier isEqualToString:@"WelcomeWindow"]) {
		completionHandler([self sharedWelcomeController].window, nil);
	}
	else {
		completionHandler(nil, nil);
	}
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
	[super encodeRestorableStateWithCoder:coder];
	
	[coder encodeObject:[self.webView mainFrameURL] forKey:kLastPageURLKey];
}

- (void)restoreStateWithCoder:(NSCoder *)coder
{
	[super restoreStateWithCoder:coder];
	
	NSString *urlString = [coder decodeObjectForKey:kLastPageURLKey];
	
	if (urlString)
		[[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	[self invalidateRestorableState];
}

- (void)awakeFromNib
{
	[[self window] setRestorationClass:[self class]];
	
	[self.webView setFrameLoadDelegate:self];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"PixenIntro" ofType:nil];
	path = [path stringByAppendingPathComponent:@"index.html"];
	NSURL *url = [NSURL fileURLWithPath:path];
	[[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
